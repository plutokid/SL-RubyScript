//!$!-CODE_START

//!$!-FUNCTION_CODE
string serializeList(list l){
    integer i=(l!=[]);//This is a hack, it gets list lenght.
    if(i)
    {
        string serialized_data = "";
        integer type = 0;
        string result;
        {@loop;
            // this custom loop is about as fast as a while loop.
            // we build the string backwords for memory reasons.
            // My kingdom for select statements....

            if(TYPE_FLOAT==(type=llGetListEntryType(l,(i=~-i)))){
                // floats get extra love
                result=(string)(llList2Float(l,i));
            }
            else if(TYPE_VECTOR==type){
                vector v=llList2Vector(l, i);
                result=(string)(v.x)+","+(string)(v.y)+","+(string)(v.z);
            }else if(TYPE_ROTATION==type){
                rotation r=llList2Rot(l,i);
                result=(string)(r.x)+","+(string)(r.y)+","+(string)(r.z)+","+(string)(r.s);
            }else{ //if ((TYPE_INTEGER == type) || (TYPE_STRING ==  type) || (TYPE_KEY == type))
                result=llList2String(l,i);// integers, strings and keys required no voodoo
			}
            if(i)
            {
                //This came to me after reverse engeneering LSL bytecode, the realization that LSL memory management sucks.
                serialized_data = "$!$" + (string)type + (serialized_data = result = ",") + result + serialized_data;
                jump loop;
            }
        }
        return (string)type + (serialized_data = result = ",") + result + serialized_data;
    }
    return "";
}

list unserializeList(string serialized_data){
    // TODO: add some checking in-case we encounter a poorly formed serialization
    //       consider using the same mem-packing list pushing technique used above
    //       (want to run performace tests first)
    list result=[];
    list t;
    list l=llParseStringKeepNulls(serialized_data, ["$!$"], []);

    string item;
    integer i=(l!=[]);//This is a hack, it gets list lenght.
    integer type = 0;
    do
    {
        if((type=(integer)(item=llList2String(l,(i=~-i)))))
        {//Little error checking (also takes care of null strings).
            integer p = llSubStringIndex(item, ",");
            item = llDeleteSubString(item, 0, p);
            // How about those switch statements, Lindens???
            if(TYPE_INTEGER==type)
            {
                t=[(integer)item];
            }
            else if(TYPE_FLOAT==type)
            {
                t = [(float)item];
            }
            else if(TYPE_STRING==type)
            {
                t = [item];
            }
            else if(TYPE_KEY==type)
            {
                t=[(key)item];
            }
            else
            {
                if (TYPE_ROTATION ^ type)
                {// if (TYPE_VECTOR == type)
                    t=[(vector)("<" + item + ">")];
                }
                else// if (TYPE_ROTATION == type)
                {
                    t=[(rotation)("<"+item+">")];
                }
            }
            result=t+result;

        }
    }while(i);
    return result;
}

default
{
    state_entry(){
    	llOwnerSay("RubyScript_Slave_MEM:"+(string)llGetFreeMemory());
    }
	link_message(integer src, integer num, string path, key id)
	{
		if(num==-426100)
		{
			list args = llParseString2List(llUnescapeURL(path),["/"],[]);
            string func = llList2String(args,0);
	    	//!$!-CALL_CODE
	    	if(resp=="n")
			{
				resp="nil";
			}
			if(resp!="")
			{
				llMessageLinked(LINK_THIS,-426101,resp,"");
			}
		}
	}
}

