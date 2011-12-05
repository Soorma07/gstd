/* Generated by vala-dbus-binding-tool 0.3.3. Do not modify! */
/* Generated with: ./vala-dbus-binding-tool --api-path=. --gdbus --strip-namespace=com --strip-namespace=ridgerun --strip-namespace=gstreamer */
using GLib;

namespace gstd {

	[DBus (name = "com.ridgerun.gstreamer.gstd.FactoryInterface", timeout = 120000)]
	public interface FactoryInterface : GLib.Object {

		[DBus (name = "Create")]
		public abstract string create(string description) throws DBusError, IOError;

		[DBus (name = "Destroy")]
		public abstract bool destroy(string path) throws DBusError, IOError;

		[DBus (name = "DestroyAll")]
		public abstract bool destroy_all() throws DBusError, IOError;

		[DBus (name = "List")]
		public abstract string[] list() throws DBusError, IOError;

		[DBus (name = "Ping")]
		public abstract bool ping() throws DBusError, IOError;
	}

	[DBus (name = "com.ridgerun.gstreamer.gstd.FactoryInterface", timeout = 120000)]
	public interface FactoryInterfaceSync : GLib.Object {

		[DBus (name = "Create")]
		public abstract string create(string description) throws DBusError, IOError;

		[DBus (name = "Destroy")]
		public abstract bool destroy(string path) throws DBusError, IOError;

		[DBus (name = "DestroyAll")]
		public abstract bool destroy_all() throws DBusError, IOError;

		[DBus (name = "List")]
		public abstract string[] list() throws DBusError, IOError;

		[DBus (name = "Ping")]
		public abstract bool ping() throws DBusError, IOError;
	}

	[DBus (name = "com.ridgerun.gstreamer.gstd.PipelineInterface", timeout = 120000)]
	public interface PipelineInterface : GLib.Object {

		[DBus (name = "PipelineSetId")]
		public abstract void pipeline_set_id(uint64 id) throws DBusError, IOError;

		[DBus (name = "PipelineGetId")]
		public abstract uint64 pipeline_get_id() throws DBusError, IOError;

		[DBus (name = "PipelineSetState")]
		public abstract bool pipeline_set_state(int state) throws DBusError, IOError;

		[DBus (name = "PipelineSetStateAsync", no_reply = true)]
		public abstract void pipeline_set_state_async(int state) throws DBusError, IOError;

		[DBus (name = "ElementSetPropertyBoolean")]
		public abstract bool element_set_property_boolean(string element, string property, bool val) throws DBusError, IOError;

		[DBus (name = "ElementSetPropertyBooleanAsnyc", no_reply = true)]
		public abstract void element_set_property_boolean_asnyc(string element, string property, bool val) throws DBusError, IOError;

		[DBus (name = "ElementSetPropertyInt")]
		public abstract bool element_set_property_int(string element, string property, int val) throws DBusError, IOError;

		[DBus (name = "ElementSetPropertyIntAsync", no_reply = true)]
		public abstract void element_set_property_int_async(string element, string property, int val) throws DBusError, IOError;

		[DBus (name = "ElementSetPropertyInt64")]
		public abstract bool element_set_property_int64(string element, string property, int64 val) throws DBusError, IOError;

		[DBus (name = "ElementSetPropertyInt64Async", no_reply = true)]
		public abstract void element_set_property_int64_async(string element, string property, int64 val) throws DBusError, IOError;

		[DBus (name = "ElementSetPropertyString")]
		public abstract bool element_set_property_string(string element, string property, string val) throws DBusError, IOError;

		[DBus (name = "ElementSetPropertyStringAsync", no_reply = true)]
		public abstract void element_set_property_string_async(string element, string property, string val) throws DBusError, IOError;

		[DBus (name = "ElementGetPropertyBoolean")]
		public abstract void element_get_property_boolean(string element, string property, out bool val, out bool success) throws DBusError, IOError;

		[DBus (name = "ElementGetPropertyInt")]
		public abstract void element_get_property_int(string element, string property, out int val, out bool success) throws DBusError, IOError;

		[DBus (name = "ElementGetPropertyInt64")]
		public abstract void element_get_property_int64(string element, string property, out int64 val, out bool success) throws DBusError, IOError;

		[DBus (name = "ElementGetPropertyString")]
		public abstract void element_get_property_string(string element, string property, out string val, out bool success) throws DBusError, IOError;

		[DBus (name = "ElementGetPropertyBuffer")]
		public abstract void element_get_property_buffer(string element, string property, out string caps, out uint8[] data, out bool success) throws DBusError, IOError;

		[DBus (name = "PipelineGetDuration")]
		public abstract int64 pipeline_get_duration() throws DBusError, IOError;

		[DBus (name = "PipelineGetPosition")]
		public abstract int64 pipeline_get_position() throws DBusError, IOError;

		[DBus (name = "PipelineSetSpeed")]
		public abstract bool pipeline_set_speed(double newrate) throws DBusError, IOError;

		[DBus (name = "PipelineSkip")]
		public abstract bool pipeline_skip(int64 period_ns) throws DBusError, IOError;

		[DBus (name = "PipelineSeek")]
		public abstract bool pipeline_seek(int64 ipos_ns) throws DBusError, IOError;

		[DBus (name = "PipelineStep")]
		public abstract void pipeline_step(uint64 frames) throws DBusError, IOError;

		[DBus (name = "PipelineSeekAsync", no_reply = true)]
		public abstract void pipeline_seek_async(int64 ipos_ns) throws DBusError, IOError;

		[DBus (name = "PipelineGetState")]
		public abstract int pipeline_get_state() throws DBusError, IOError;

		[DBus (name = "ElementGetState")]
		public abstract int element_get_state(string element) throws DBusError, IOError;

		[DBus (name = "PipelineSendEos")]
		public abstract void pipeline_send_eos() throws DBusError, IOError;

		[DBus (name = "PipelineSendEosAsync", no_reply = true)]
		public abstract void pipeline_send_eos_async() throws DBusError, IOError;

		[DBus (name = "PipelineSendCustomEvent")]
		public abstract bool pipeline_send_custom_event(string type, string name) throws DBusError, IOError;

		[DBus (name = "PipelineSendCustomEventAsync", no_reply = true)]
		public abstract void pipeline_send_custom_event_async(string type, string name) throws DBusError, IOError;

		[DBus (name = "SetWindowId")]
		public abstract void set_window_id(uint64 winId) throws DBusError, IOError;

		[DBus (name = "Ping")]
		public abstract bool ping() throws DBusError, IOError;

		[DBus (name = "ElementSetState")]
		public abstract bool element_set_state(string element, int state) throws DBusError, IOError;

		[DBus (name = "ElementSetStateAsync", no_reply = true)]
		public abstract void element_set_state_async(string element, int state) throws DBusError, IOError;

		[DBus (name = "Eos")]
		public signal void eos(uint64 pipe_id);

		[DBus (name = "Error")]
		public signal void error(uint64 pipe_id, string err_message);

		[DBus (name = "StateChanged")]
		public signal void state_changed(uint64 pipe_id, int old_state, int new_state, string src);

		[DBus (name = "Qos")]
		public signal void qos(uint64 pipe_id, bool live, uint64 running_time, uint64 stream_time, uint64 timestamp, uint64 duration, int64 jitter, double proportion, int quality, int format, uint64 processed, uint64 dropped);
	}

	[DBus (name = "com.ridgerun.gstreamer.gstd.PipelineInterface", timeout = 120000)]
	public interface PipelineInterfaceSync : GLib.Object {

		[DBus (name = "PipelineSetId")]
		public abstract void pipeline_set_id(uint64 id) throws DBusError, IOError;

		[DBus (name = "PipelineGetId")]
		public abstract uint64 pipeline_get_id() throws DBusError, IOError;

		[DBus (name = "PipelineSetState")]
		public abstract bool pipeline_set_state(int state) throws DBusError, IOError;

		[DBus (name = "PipelineSetStateAsync", no_reply = true)]
		public abstract void pipeline_set_state_async(int state) throws DBusError, IOError;

		[DBus (name = "ElementSetPropertyBoolean")]
		public abstract bool element_set_property_boolean(string element, string property, bool val) throws DBusError, IOError;

		[DBus (name = "ElementSetPropertyBooleanAsnyc", no_reply = true)]
		public abstract void element_set_property_boolean_asnyc(string element, string property, bool val) throws DBusError, IOError;

		[DBus (name = "ElementSetPropertyInt")]
		public abstract bool element_set_property_int(string element, string property, int val) throws DBusError, IOError;

		[DBus (name = "ElementSetPropertyIntAsync", no_reply = true)]
		public abstract void element_set_property_int_async(string element, string property, int val) throws DBusError, IOError;

		[DBus (name = "ElementSetPropertyInt64")]
		public abstract bool element_set_property_int64(string element, string property, int64 val) throws DBusError, IOError;

		[DBus (name = "ElementSetPropertyInt64Async", no_reply = true)]
		public abstract void element_set_property_int64_async(string element, string property, int64 val) throws DBusError, IOError;

		[DBus (name = "ElementSetPropertyString")]
		public abstract bool element_set_property_string(string element, string property, string val) throws DBusError, IOError;

		[DBus (name = "ElementSetPropertyStringAsync", no_reply = true)]
		public abstract void element_set_property_string_async(string element, string property, string val) throws DBusError, IOError;

		[DBus (name = "ElementGetPropertyBoolean")]
		public abstract void element_get_property_boolean(string element, string property, out bool val, out bool success) throws DBusError, IOError;

		[DBus (name = "ElementGetPropertyInt")]
		public abstract void element_get_property_int(string element, string property, out int val, out bool success) throws DBusError, IOError;

		[DBus (name = "ElementGetPropertyInt64")]
		public abstract void element_get_property_int64(string element, string property, out int64 val, out bool success) throws DBusError, IOError;

		[DBus (name = "ElementGetPropertyString")]
		public abstract void element_get_property_string(string element, string property, out string val, out bool success) throws DBusError, IOError;

		[DBus (name = "ElementGetPropertyBuffer")]
		public abstract void element_get_property_buffer(string element, string property, out string caps, out uint8[] data, out bool success) throws DBusError, IOError;

		[DBus (name = "PipelineGetDuration")]
		public abstract int64 pipeline_get_duration() throws DBusError, IOError;

		[DBus (name = "PipelineGetPosition")]
		public abstract int64 pipeline_get_position() throws DBusError, IOError;

		[DBus (name = "PipelineSetSpeed")]
		public abstract bool pipeline_set_speed(double newrate) throws DBusError, IOError;

		[DBus (name = "PipelineSkip")]
		public abstract bool pipeline_skip(int64 period_ns) throws DBusError, IOError;

		[DBus (name = "PipelineSeek")]
		public abstract bool pipeline_seek(int64 ipos_ns) throws DBusError, IOError;

		[DBus (name = "PipelineStep")]
		public abstract void pipeline_step(uint64 frames) throws DBusError, IOError;

		[DBus (name = "PipelineSeekAsync", no_reply = true)]
		public abstract void pipeline_seek_async(int64 ipos_ns) throws DBusError, IOError;

		[DBus (name = "PipelineGetState")]
		public abstract int pipeline_get_state() throws DBusError, IOError;

		[DBus (name = "ElementGetState")]
		public abstract int element_get_state(string element) throws DBusError, IOError;

		[DBus (name = "PipelineSendEos")]
		public abstract void pipeline_send_eos() throws DBusError, IOError;

		[DBus (name = "PipelineSendEosAsync", no_reply = true)]
		public abstract void pipeline_send_eos_async() throws DBusError, IOError;

		[DBus (name = "PipelineSendCustomEvent")]
		public abstract bool pipeline_send_custom_event(string type, string name) throws DBusError, IOError;

		[DBus (name = "PipelineSendCustomEventAsync", no_reply = true)]
		public abstract void pipeline_send_custom_event_async(string type, string name) throws DBusError, IOError;

		[DBus (name = "SetWindowId")]
		public abstract void set_window_id(uint64 winId) throws DBusError, IOError;

		[DBus (name = "Ping")]
		public abstract bool ping() throws DBusError, IOError;

		[DBus (name = "ElementSetState")]
		public abstract bool element_set_state(string element, int state) throws DBusError, IOError;

		[DBus (name = "ElementSetStateAsync", no_reply = true)]
		public abstract void element_set_state_async(string element, int state) throws DBusError, IOError;

		[DBus (name = "Eos")]
		public signal void eos(uint64 pipe_id);

		[DBus (name = "Error")]
		public signal void error(uint64 pipe_id, string err_message);

		[DBus (name = "StateChanged")]
		public signal void state_changed(uint64 pipe_id, int old_state, int new_state, string src);

		[DBus (name = "Qos")]
		public signal void qos(uint64 pipe_id, bool live, uint64 running_time, uint64 stream_time, uint64 timestamp, uint64 duration, int64 jitter, double proportion, int quality, int format, uint64 processed, uint64 dropped);
	}
}
