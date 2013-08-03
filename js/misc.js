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
     //console.log("/namegenerator?type=json&gentype="+document.getElementById("gentype").value+"&count="+document.getElementById("count").value+"&race="+document.getElementById("race").value);
        $.ajax({
            url: "/namegenerator?type=json&gentype="+document.getElementById("gentype").value+"&count="+document.getElementById("count").value+"&race="+document.getElementById("race").value,
            dataType: "json",
        }).done(function(data) {
            //console.log(data);           
             
            document.getElementById("gen_result").innerHTML='<h3>seed: '+ data.seed +'<ol>';
            
            for (var item in data.names) {
                document.getElementById("gen_result").innerHTML+='<li>'+data.names[item]+'</li>';
            }
            document.getElementById("gen_result").innerHTML+='</ol>';
        });
 
    }
    //   condensed awesomeness  http://davidbau.com/archives/2010/01/30/random_seeds_coded_hints_and_quintillions.html
    // allows for seeding of random. it's random enough, STFU. 
    (function(j,i,g,m,k,n,o){function q(b){var e,f,a=this,c=b.length,d=0,h=a.i=a.j=a.m=0;a.S=[];a.c=[];for(c||(b=[c++]);d<g;)a.S[d]=d++;for(d=0;d<g;d++)e=a.S[d],h=h+e+b[d%c]&g-1,f=a.S[h],a.S[d]=f,a.S[h]=e;a.g=function(b){var c=a.S,d=a.i+1&g-1,e=c[d],f=a.j+e&g-1,h=c[f];c[d]=h;c[f]=e;for(var i=c[e+h&g-1];--b;)d=d+1&g-1,e=c[d],f=f+e&g-1,h=c[f],c[d]=h,c[f]=e,i=i*g+c[e+h&g-1];a.i=d;a.j=f;return i};a.g(g)}function p(b,e,f,a,c){f=[];c=typeof b;if(e&&c=="object")for(a in b)if(a.indexOf("S")<5)try{f.push(p(b[a],e-1))}catch(d){}return f.length?f:b+(c!="string"?"\0":"")}function l(b,e,f,a){b+="";for(a=f=0;a<b.length;a++){var c=e,d=a&g-1,h=(f^=e[a&g-1]*19)+b.charCodeAt(a);c[d]=h&g-1}b="";for(a in e)b+=String.fromCharCode(e[a]);return b}i.seedrandom=function(b,e){var f=[],a;b=l(p(e?[b,j]:arguments.length?b:[(new Date).getTime(),j,window],3),f);a=new q(f);l(a.S,j);i.random=function(){for(var c=a.g(m),d=o,b=0;c<k;)c=(c+b)*g,d*=g,b=a.g(1);for(;c>=n;)c/=2,d/=2,b>>>=1;return(c+b)/d};return b};o=i.pow(g,m);k=i.pow(2,k);n=k*2;l(i.random(),j)})([],Math,256,6,52);

