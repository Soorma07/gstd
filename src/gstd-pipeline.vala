/*
 * gstd/src/gstd-pipeline.vala
 *
 * GStreamer daemon Pipeline class - framework for controlling audio and video streaming using D-Bus messages
 *
 * Copyright (c) 2010, RidgeRun
 * All rights reserved.
 *
 * GPL2 license - See http://www.opensource.org/licenses/gpl-2.0.php for complete text.
 */

namespace gstd
{

public class Pipeline : GLib.Object, PipelineInterface
{
	/* Private data */
	private Gst.Element _pipeline;
	private uint64 _id = 0;
	private bool _initialized = false;
	private string _path = "";
	private double _rate = 1.0;
	private uint64 _windowId = 0;

	/**
	   Create a new instance of a Pipeline
	   @param description, gst-launch style string description of the pipeline
	   @param ids, pipeline identifier
	 */
	public Pipeline (string description)
	{
		try
		{
			/* Create the pipe */
			_pipeline = Gst.parse_launch (description) as Gst.Element;

			/*Get and watch bus */
			Gst.Bus bus = _pipeline.get_bus ();
			bus.set_sync_handler(bus_sync_callback);
			bus.add_watch (bus_callback);
			/* The bus watch increases our ref count, so we need to unreference
			 * ourselfs in order to provide properly release behavior of this
			 * object
			 */
			unref();

			/* Set pipeline state to initialized */
			_initialized = true;
			Posix.syslog (Posix.LOG_NOTICE, "Pipeline created, %s", description);
		}
		catch (GLib.Error e)
		{
			Posix.syslog (Posix.LOG_ERR, "Error constructing pipeline, %s", e.message);
		}
	}

	/**
	   Destroy a instance of a Pipeline
	 */
	~Pipeline ()
	{
		/* Destroy the pipeline */
		if (_initialized)
		{
			if (!pipeline_set_state_impl (Gst.State.NULL))
				Posix.syslog (Posix.LOG_ERR, "Failed to destroy pipeline");
		}
	}

	private Gst.BusSyncReply bus_sync_callback (Gst.Bus bus, Gst.Message message)
	{
		if (_windowId == 0)
			return Gst.BusSyncReply.PASS;

		unowned Gst.Structure ? st = message.get_structure();
		if (!(st != null && st.has_name("prepare-xwindow-id")))
			return Gst.BusSyncReply.PASS;

		Posix.syslog (Posix.LOG_DEBUG, "requested xwindow-id");
		var pipe = _pipeline as Gst.Pipeline;
		GLib.assert(pipe != null);

		var sink = pipe.get_child_by_name("videosink") as Gst.Element;
		if (sink == null)
			return Gst.BusSyncReply.PASS;

		var overlay = sink as Gst.XOverlay;
		if (overlay == null)
			return Gst.BusSyncReply.PASS;

		Posix.syslog (Posix.LOG_DEBUG, "set xwindow-id %llu", _windowId);
		overlay.set_xwindow_id((ulong)_windowId);

		return Gst.BusSyncReply.PASS;
	}

	private bool bus_callback (Gst.Bus bus, Gst.Message message)
	{
		Posix.syslog (Posix.LOG_DEBUG, "received message %s", message.type.to_string());
		switch (message.type)
		{
			case Gst.MessageType.ERROR :

				GLib.Error err;
				string dbg;

				/*Parse error */
				message.parse_error (out err, out dbg);

				/*Sending Error Signal */
				error(_id, err.message);

				Posix.syslog (Posix.LOG_DEBUG, "Error on pipeline, %s", err.message);
				break;

			case Gst.MessageType.EOS:

				/*Sending Eos Signal */
				eos (_id);
				break;

			case Gst.MessageType.STATE_CHANGED:

				Gst.State oldstate;
				Gst.State newstate;
				Gst.State pending;

				string src = (message.src as Gst.Element).get_name ();
				message.parse_state_changed (out oldstate, out newstate,
				                             out pending);
				
				Posix.syslog (Posix.LOG_INFO, "%s,changes state from %s to %s", src, oldstate.to_string (), newstate.to_string ());

				/*Sending StateChanged Signal */
				state_changed (_id, oldstate, newstate, src);
				break;

#if GSTREAMER_SUPPORT_QOS_SIGNAL
			case Gst.MessageType.QOS:
				bool live;
		                uint64 running_time;
		                uint64 stream_time;
		                uint64 timestamp;
		                uint64 duration;
		                int64 jitter;
		                double proportion;
		                int quality;
		                int format;
		                uint64 processed;
		                uint64 dropped;

				//plase note, if this doesn't compile, you need to apply gstreamer-0.10.vapi.patch
				message.parse_qos(out live, out running_time, out stream_time, out timestamp, out duration);
				message.parse_qos_values(out jitter, out proportion, out quality);
				Gst.Format fmt;
				message.parse_qos_stats(out fmt, out processed, out dropped);
				format = fmt;

				qos(_id, live, running_time, stream_time, timestamp, duration, jitter, proportion, quality, format, processed, dropped);
				break;
#endif
			default:
				break;
		}

		return true;
	}

	private bool pipeline_set_state_impl (Gst.State state)
	{
		_pipeline.set_state (state);

		/* Wait until state change is done */
		Gst.State current, pending;
		_pipeline.get_state (out current, out pending, (Gst.ClockTime)(Gst.CLOCK_TIME_NONE)); // Block
		if (current != state)
		{
			Posix.syslog (Posix.LOG_ERR, "Pipeline failed to change state to %s", state.to_string ());
			return false;
		}
		return true;
	}

	public bool pipeline_set_state (int state)
	{
		return pipeline_set_state_impl((Gst.State)(state));
	}

	private void pipeline_set_state_async_impl(Gst.State state)
	{
		_pipeline.set_state (state);
	}
	
	public void pipeline_set_state_async(int state)
	{
		pipeline_set_state_async_impl((Gst.State)(state));
	}

	/**
	   Returns initialized flag value.
	 */
	public bool pipeline_is_initialized ()
	{
		return _initialized;
	}

	/**
           Gets the id of the pipe.
          */
	public uint64 pipeline_get_id()
	{
		return _id;
	}

	/**
           Sets the id of the pipe.
          */
	public void pipeline_set_id(uint64 id)
	{
		_id = id;
	}

	/**
	   Returns the dbus-path assigned when created
	 */
	public string pipeline_get_path()
	{
		return _path;
	}

	/**
	   Sets a dbus-path,this is assigned when connected to daemon
	 */
	public bool pipeline_set_path (string dbuspath)
	{
		_path = dbuspath;
		return true;
	}

	/**
	   Gets the pipeline state
	 */
	public int pipeline_get_state ()
	{
		Gst.State current, pending;
		_pipeline.get_state (out current, out pending, (Gst.ClockTime)(Gst.CLOCK_TIME_NONE)); // Block
		return current;
	}

	/**
	   Sets a boolean property for an element on the pipeline
	   @param element, whose property needs to be set
	   @param property,property name
	   @param val, bool property value
	 */
	public bool element_set_property_boolean (string element, string property, bool val)
	{
		var pipe = _pipeline as Gst.Pipeline;
		var e = pipe.get_child_by_name (element) as Gst.Element;
		if (e == null)
		{
			Posix.syslog (Posix.LOG_WARNING, "Element %s not found on pipeline", element);
			return false;
		}

		var spec = e.get_class ().find_property (property);
		if (spec == null)
		{
			Posix.syslog (Posix.LOG_WARNING, "Element %s does not have the property %s",
					element, property);
			return false;
		}

		e.set (property, val, null);
		return true;
	}
	
	public void element_set_property_boolean_asnyc (string element, string property, bool val)
	{
		try
		{
			element_set_property_boolean(element, property, val);
		}
		catch (Error err)
		{
		}
	}

	/**
	   Sets an int property for an element on the pipeline
	   @param element, whose property needs to be set
	   @param property,property name
	   @param val, int property value
	 */
	public bool element_set_property_int (string element, string property, int val)
	{
		var pipe = _pipeline as Gst.Pipeline;
		var e = pipe.get_child_by_name (element) as Gst.Element;
		if (e == null)
		{
			Posix.syslog (Posix.LOG_WARNING, "Element %s not found on pipeline", element);
			return false;
		}

		var spec = e.get_class ().find_property (property);
		if (spec == null)
		{
			Posix.syslog (Posix.LOG_WARNING, "Gstd: Element %s does not have the property %s",
				              element, property);
			return false;
		}
		e.set (property, val, null);

		return true;
	}
	
	public void element_set_property_int_async (string element, string property, int val)
	{
		try
		{
			element_set_property_int(element, property, val);
		}
		catch (Error err)
		{
		}
	}

	/**
	   Sets an long property for an element on the pipeline
	   @param element, whose property needs to be set
	   @param property,property name
	   @param val, long property value     */
	public bool element_set_property_int64 (string element, string property, int64 val)
	{
		var pipe = _pipeline as Gst.Pipeline;
		var e = pipe.get_child_by_name (element) as Gst.Element;
		if (e == null)
		{
			Posix.syslog (Posix.LOG_WARNING, "Element %s not found on pipeline", element);
			return false;
		}

		var spec = e.get_class ().find_property (property);
		if (spec == null)
		{
			Posix.syslog (Posix.LOG_WARNING, "Element %s does not have the property %s",
				              element, property);
			return false;
		}

		e.set (property, val, null);
		return true;
	}
	
	public void element_set_property_int64_async (string element, string property, int64 val)
	{
		try
		{
			element_set_property_int64(element, property, val);
		}
		catch (Error err)
		{
		}
	}

	/**
	   Sets a string property for an element on the pipeline
	   @param element, whose property needs to be set
	   @param property,property name
	   @param val,string property value
	 */
	public bool element_set_property_string (string element, string property, string val)
	{
		var pipe = _pipeline as Gst.Pipeline;
		var e = pipe.get_child_by_name (element) as Gst.Element;
		if (e == null)
		{
			Posix.syslog (Posix.LOG_WARNING, "Element %s not found on pipeline", element);
			return false;
		}

		var spec = e.get_class ().find_property (property);
		if (spec == null)
		{
			Posix.syslog (Posix.LOG_WARNING, "Element %s does not have the property %s",
				              element, property);
			return false;
		}

		e.set (property, val, null);

		return true;
	}
	
	public void element_set_property_string_async (string element, string property, string val)
	{
		try
		{
			element_set_property_string(element, property, val);
		}
		catch (Error err)
		{
		}
	}

	public void element_get_property_boolean(string element, string property, out bool val, out bool success)
	{
		success = element_get_property_boolean_impl(element, property, out val);
	}

	/**
	   Gets an element's bool property value of a specific pipeline
	   @param element, whose property value wants to be known
	   @param property,property name
	 */
	private bool element_get_property_boolean_impl (string element, string property, out bool val)
	{
		val = false;

		var pipe = _pipeline as Gst.Pipeline;
		var e = pipe.get_child_by_name (element) as Gst.Element;
		if (e == null)
		{
			Posix.syslog (Posix.LOG_WARNING, "Element %s not found on pipeline", element);
			return false;
		}

		var spec = e.get_class ().find_property (property);
		if (spec == null)
		{
			Posix.syslog (Posix.LOG_WARNING, "Element %s does not have the property %s",
				              element, property);
			return false;
		}

		e.get (property, &val, null);
		return true;
	}

	public void element_get_property_int(string element, string property, out int val, out bool success)
	{
		success = element_get_property_int_impl(element, property, out val);
	}

	/**
	   Gets an element's int property value of a specific pipeline
	   @param element, whose property value wants to be known
	   @param property,property name
	   @param val value of the property
	 */
	private bool element_get_property_int_impl (string element, string property, out int val)
	{
		val = 0;

		var pipe = _pipeline as Gst.Pipeline;
		var e = pipe.get_child_by_name (element) as Gst.Element;
		if (e == null)
		{
			Posix.syslog (Posix.LOG_WARNING, "Element %s not found on pipeline", element);
			return false;
		}

		var spec = e.get_class ().find_property (property);
		if (spec == null)
		{
			Posix.syslog (Posix.LOG_WARNING, "Element %s does not have the property %s",
				              element, property);
			return false;
		}

		e.get (property, &val, null);
		return true;
	}

	public void element_get_property_int64(string element, string property, out int64 val, out bool success)
	{
		success = element_get_property_int64_impl(element, property, out val);
	}

	/**
	   Gets an element's long property value of a specific pipeline
	   @param element, whose property value wants to be known
	   @param property,property name
	   @param val value of the property
	 */
	private bool element_get_property_int64_impl (string element, string property, out int64 val)
	{
		val = 0;

		var pipe = _pipeline as Gst.Pipeline;
		var e = pipe.get_child_by_name (element) as Gst.Element;
		if (e == null)
		{
			Posix.syslog (Posix.LOG_WARNING, "Element %s not found on pipeline", element);
			return false;
		}

		var spec = e.get_class ().find_property (property);
		if (spec == null)
		{
			Posix.syslog (Posix.LOG_WARNING, "Element %s does not have the property %s",
				              element, property);
			return false;
		}

		e.get (property, &val, null);
		return true;
	}

	public void element_get_property_string(string element, string property, out string val, out bool success)
	{
		success = element_get_property_string_impl(element, property, out val);
	}

	/**
	   Gets an element's string property value of a specific pipeline
	   @param element, whose property value wants to be known
	   @param property,property name
	   @param val value of the property
	 */
	private bool element_get_property_string_impl (string element, string property, out string val)
	{
		val = "";

		var pipe = _pipeline as Gst.Pipeline;
		var e = pipe.get_child_by_name (element) as Gst.Element;
		if (e == null)
		{
			Posix.syslog (Posix.LOG_WARNING, "Element %s not found on pipeline", element);
			return false;
		}

		var spec = e.get_class ().find_property (property);
		if (spec == null)
		{
			Posix.syslog (Posix.LOG_WARNING, "Element %s does not have the property %s",
				              element, property);
			return false;
		}

		e.get (property, &val, null);
		return true;
	}
	
	/**
	   Gets an element's state value of a specific pipeline
	   @param element, whose property value wants to be known
	   @param val value of the property
	 */
	public int element_get_state (string element)
	{
		//Posix.syslog (Posix.LOG_INFO, "Searching element %s on pipeline.", element);
		var pipe = _pipeline as Gst.Pipeline;
		var e = pipe.get_child_by_name (element) as Gst.Element;
		if (e == null)
		{
			Posix.syslog (Posix.LOG_WARNING, "Element %s not found on pipeline %s", element, pipe.get_name());
			return Gst.State.NULL;
		}
		
		// Simply return the current state. Ignore possible state changes
		Gst.State current, pending;
		e.get_state ( out current, out pending, (Gst.ClockTime)(Gst.CLOCK_TIME_NONE)); // Block
		return current;
	}

	public void element_get_property_buffer(string element, string property, out string caps, out uint8[] data, out bool success)
	{
		success = element_get_property_buffer_impl(element, property, out caps, out data);
	}

	/**
	   Gets an element's buffer property value of a specific pipeline
	   @param element, whose property value wants to be known
	   @param property,property name
	   @param caps caps of buffer
	   @param data data
	 */
	private bool element_get_property_buffer_impl (string element, string property, out string caps, out uint8[] data)
	{
		caps = "";
		data = new uint8[0];

		var pipe = _pipeline as Gst.Pipeline;
		var e = pipe.get_child_by_name (element) as Gst.Element;
		if (e == null)
		{
			Posix.syslog (Posix.LOG_WARNING, "Element %s not found on pipeline", element);
			return false;
		}

		var spec = e.get_class ().find_property (property);
		if (spec == null)
		{
			Posix.syslog (Posix.LOG_WARNING, "Element %s does not have the property %s",
				              element, property);
			return false;
		}

		Gst.Buffer buffer = null;
		e.get (property, &buffer, null);

		if (buffer != null)
		{
			caps = (buffer.caps != null) ? buffer.caps.to_string() : "";
			data = buffer.data;
		}

		return true;
	}

	/**
	   Query duration to a pipeline on the server
	   @return time in milliseconds or null if not available
	 */
	public int64 pipeline_get_duration ()
	{
		/* Query duration */
		var format = Gst.Format.TIME;
		int64 duration = 0;
		if (!_pipeline.query_duration (ref format, out duration))
		{
			return -1;
		}

		if (duration == Gst.CLOCK_TIME_NONE)
			return -1;

		Posix.syslog (Posix.LOG_DEBUG, "Duration at server is %u:%02u:%02u.%03u",
			      (uint)(duration / (Gst.SECOND * 60 * 60)),
			      (uint)((duration / (Gst.SECOND * 60)) % 60),
			      (uint)((duration / Gst.SECOND) % 60),
			      (uint)(duration % Gst.SECOND));

		return duration;
	}

	/**
	   Query position to a pipeline on the server
	   @return position in milliseconds or null if not available
	 */
	public int64 pipeline_get_position ()
	{
		var format = Gst.Format.TIME;
		int64 position = 0;

		if (!_pipeline.query_position (ref format, out position))
		{
			return -1;
		}

		if (position == Gst.CLOCK_TIME_NONE)
			return -1;

		Posix.syslog (Posix.LOG_DEBUG, "Position at server is %u:%02u:%02u.%03u",
			      (uint)(position / (Gst.SECOND * 60 * 60)),
			      (uint)((position / (Gst.SECOND * 60)) % 60),
			      (uint)((position / Gst.SECOND) % 60),
			      (uint)(position % Gst.SECOND));
		return position;
	}

	private bool pipeline_seek_impl (int64 ipos_ns)
	{
		/*Set the current position */
		if (!_pipeline.seek (_rate, Gst.Format.TIME, Gst.SeekFlags.FLUSH, Gst.SeekType.SET, ipos_ns, Gst.SeekType.NONE, Gst.CLOCK_TIME_NONE))
		{
			Posix.syslog (Posix.LOG_WARNING, "Media type not seekable");
			return false;
		}
		return true;
	}
	
	/**
	   Seeks a specific time position.
	   Data in the pipeline is flushed.
	   @param ipos_ns, absolute position in nanoseconds
	 */
	public bool pipeline_seek (int64 ipos_ns)
	{
		return pipeline_seek_impl(ipos_ns);
	}

	/**
	   Seeks a specific time position.
	   Data in the pipeline is flushed.
	   @param ipos_ms, absolute position in nanoseconds
	 */
	public void pipeline_seek_async (int64 ipos_ns)
	{
		pipeline_seek_impl(ipos_ns);
	}

	/**
	   Skips time, it moves position forward and backwards from
	   the current position.
	   Data in the pipeline is flushed.
	   @param period_ms, relative time in milliseconds
	 */
	public bool pipeline_skip (int64 period_ns)
	{
		var format = Gst.Format.TIME;
		int64 cur_pos_ns = 0;

		/*Gets the current position */
		if (!_pipeline.query_position (ref format, out cur_pos_ns))
		{
			return false;
		}

		/*Sets the new position relative to the current one */
		int64 seek_ns = cur_pos_ns + period_ns;

		/*Set the current position */
		if (!_pipeline.seek (_rate, format, Gst.SeekFlags.FLUSH, Gst.SeekType.SET, seek_ns, Gst.SeekType.NONE, Gst.CLOCK_TIME_NONE))
		{
			Posix.syslog (Posix.LOG_WARNING, "Media type not seekable");
			return false;
		}
		return true;
	}

	/**
	   Changes pipeline speed, it enable fast|slow foward and
	   fast|slow -reverse playback
	   @param new_rate, values great than zero play forward, reverse
	        otherwise.  Values greater than 1 (or -1 for reverse)
	        play faster than normal, otherwise slower than normal.
	 */
	public bool pipeline_set_speed (double new_rate)
	{
		/*Sets the new rate */
		_rate = new_rate;

		/*Changes the rate on the pipeline */
		if (!_pipeline.seek (_rate, Gst.Format.TIME, Gst.SeekFlags.SKIP | Gst.SeekFlags.FLUSH, Gst.SeekType.NONE, Gst.CLOCK_TIME_NONE, Gst.SeekType.NONE, Gst.CLOCK_TIME_NONE))
		{
			Posix.syslog (Posix.LOG_WARNING, "Speed could not be changed");
			return false;
		}
		return true;
	}

	public void pipeline_send_eos ()
	{
		_pipeline.send_event(new Gst.Event.eos());
	}
	
	public void pipeline_send_eos_async ()
	{
		try
		{
			pipeline_send_eos();
		}
		catch (Error err)
		{
		}
	}

	public void pipeline_step (uint64 frames)
	{
#if GSTREAMER_SUPPORT_STEP
		pipeline_set_state_impl (Gst.State.PAUSED);
		_pipeline.send_event(new Gst.Event.step(Gst.Format.BUFFERS,frames,1.0,true,false));
#else
		Posix.syslog (Posix.LOG_ERR, "Your GStreamer version doesnt support step, need > 0.10.24\n");
#endif
	}

	public bool pipeline_send_custom_event(string stype, string name)
	{
		Gst.EventType type;

		switch (stype.down () ) {
			case "upstream":
				type = Gst.EventType.CUSTOM_UPSTREAM;
				break;
			case "downstream":
				type = Gst.EventType.CUSTOM_DOWNSTREAM;
				break;
			case "downstream_oob":
				type = Gst.EventType.CUSTOM_DOWNSTREAM_OOB;
				break;
			case "both":
				type = Gst.EventType.CUSTOM_BOTH;
				break;
			case "both_oob":
				type = Gst.EventType.CUSTOM_BOTH_OOB;
				break;
			default:
				return false;
		}
		_pipeline.send_event(new Gst.Event.custom(type, new Gst.Structure.empty(name)));

		return true;
	}
	
	public void pipeline_send_custom_event_async(string stype, string name)
	{
		try
		{
			pipeline_send_custom_event(stype, name);
		}
		catch (Error err)
		{
		}
	}

	/**
	   Sets an element to the specified state
	   @param element, whose state is to be set
	   @param state, desired element state
	 */
	public bool element_set_state (string element, int state)
	{
		var pipe = _pipeline as Gst.Pipeline;
		var e = pipe.get_child_by_name(element) as Gst.Element;
		if (e == null)
		{
			Posix.syslog (Posix.LOG_WARNING, "Element %s not found on pipeline", element);
			return false;
		}

		e.set_state ((Gst.State)(state));

		/* Wait for the transition at most 8 secs */
		Gst.State current, pending;
		e.get_state (out current, out pending, (Gst.ClockTime) Gst.CLOCK_TIME_NONE);
		if (current != state)
		{
			Posix.syslog (Posix.LOG_ERR, "Element, failed to change state %s", state.to_string ());
			return false;
		}
		return true;
	}

	/**
	   Sets an element to the specified state, returning before the state change may have occurred
	   @param element, whose state is to be set
	   @param state, desired element state
	 */
	public void element_set_state_async (string element, int state)
	{
		var pipe = _pipeline as Gst.Pipeline;
		var e = pipe.get_child_by_name (element) as Gst.Element;
		if (e == null)
		{
			Posix.syslog (Posix.LOG_WARNING, "Element %s not found on pipeline", element);
		}
		e.set_state ((Gst.State)(state));
	}

	public void set_window_id(uint64 winId)    //use uint64, because dbus-binding can't map type "ulong"
	{
		_windowId = winId;
	}
	
	/**
	   Ping pipeline..
	   @return true if alive
	 */
	public bool ping ()
	{
		return true;
	}
}

}

