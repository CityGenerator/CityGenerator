    function toggleGlobalMenu(id) {
       var e = document.getElementById('globalmenudrawer');
       if(e.style.display == 'block')
          e.style.display = 'none';
       else
          e.style.display = 'block';
    }


    function showgenerator(gentype){
        if (document.getElementById(gentype+"_specific")){
            document.getElementById(gentype+"_specific").style.display = 'inline-block';
        }else{
            document.getElementById("npc_specific").style.display = 'none';
        } 

    }

    function generate_names(){
     console.log("/namegenerator?type=json&gentype="+document.getElementById("gentype").value+"&count="+document.getElementById("count").value+"&race="+document.getElementById("race").value);
        $.ajax({
            url: "/namegenerator?type=json&gentype="+document.getElementById("gentype").value+"&count="+document.getElementById("count").value+"&race="+document.getElementById("race").value,
            dataType: "json",
        }).done(function(data) {
            console.log(data);           
             
            document.getElementById("gen_result").innerHTML='<h3>seed: '+ data.seed +'<ol>';
            
            for (var item in data.names) {
                document.getElementById("gen_result").innerHTML+='<li>'+data.names[item]+'</li>';
            }
            document.getElementById("gen_result").innerHTML+='</ol>';
        });
 
    }

