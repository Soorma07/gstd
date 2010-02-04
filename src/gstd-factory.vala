using Gst;

[DBus (name = "com.ridgerun.gstreamer.gstd.FactoryInterface")]

public class Factory : GLib.Object {
    private int next_id;
    private Pipeline[] pipes;

    /**
     Create a new instance of a factory server 
     */
    public Factory(){
        next_id = 0;
        pipes = new Pipeline[20];
        for(int ids=0; ids<20; ids++){
            pipes[ids] = null;
        }
    }

    /**
     Creates a pipeline from a gst-launch like descrition
     @param description, gst-launch like description of the pipeline
     @return the dbus-path of the pipeline
     */
    public string Create(string description){

        /* Create our pipeline*/
        while (pipes[next_id] != null){
            next_id = next_id++ % 20;
        }
        pipes[next_id] = new Pipeline(description,next_id);

        if (pipes[next_id].PipelineIsInitialized()){
            string objectpath = "/com/ridgerun/gstreamer/gstd/pipe" + next_id.to_string();
            conn.register_object (objectpath, pipes[next_id]);
            pipes[next_id].PipelineSetPath(objectpath);
            next_id++;
            return objectpath;
        }
        return "";
    }

    public string CreateWithDebug(string description,bool debug){

        if(debug){
            /* Create our pipeline*/
            while (pipes[next_id] != null){
                next_id = next_id++ % 20;
            }
            pipes[next_id] = new Pipeline.withDebug(description,next_id,debug);

            if (pipes[next_id].PipelineIsInitialized()){
                string objectpath = "/com/ridgerun/gstreamer/gstd/pipe" + next_id.to_string();
                conn.register_object (objectpath, pipes[next_id]);
                next_id++;
                return objectpath;
            }
            return "";
        }else { 
            string ret = Create(description);
            return ret;
        }
    }

    /**
     Destroy a pipeline from a gst-launch like description
     @param objectpath, the dbus-objectpathe of the pipeline
     @return true,if succeded
     */
    public bool Destroy(int id){

        if (id == -1){
            stderr.printf("Fail to destroy pipeline\n");
            return false;
        }

        pipes[id] = null;
        return true;
    }

    /**
     List the existing pipelines
     @return pipe_list with the corresponding paths
     */
    public string[] List(){

        int counter = 0;
        int index = 0;
        string[] pipelist = new string[20];

        for(index=0; index<20;index++){
            if (pipes[index] != null){
                pipelist[counter]=pipes[index].PipelineGetPath();
                counter++;
            }
        }
        for(index=0; index<pipelist.length; index++){
            stdout.printf("  %i.%s\n",index,pipelist[index]);
        }
        stdout.printf("Everything is fine before returning\n");
        return pipelist;

    }
}