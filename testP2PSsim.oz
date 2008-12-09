declare
[P2PS]={Module.link ["/Users/erick/Desktop/DistributedWikipedia/p2ps-scm-2008-12-06/trunk/P2PSNode.ozf"]}

declare
N1={P2PS.newP2PSNode args(dist:sim transactions:true)}
N2={P2PS.newP2PSNode args(dist:sim transactions:true)}
N3={P2PS.newP2PSNode args(dist:sim transactions:true)}
N4={P2PS.newP2PSNode args(dist:sim transactions:true)}
N5={P2PS.newP2PSNode args(dist:sim transactions:true)}

declare
RingRef={N1 getRingRef($)}
{N2 join(RingRef)}
{N3 join(RingRef)}
{N4 join(RingRef)}
{N5 join(RingRef)}


% Browse basic structure
{Browse {N1 getSuccRef($)}#{N1 getId($)}}
{Browse {N2 getSuccRef($)}#{N2 getId($)}}
{Browse {N3 getSuccRef($)}#{N3 getId($)}}
{Browse {N4 getSuccRef($)}#{N4 getId($)}}
{Browse {N5 getSuccRef($)}#{N5 getId($)}}

% Fail a node and check structure
% {N3 injectPermFail}

% {Browse '-------- After failing of N3 ---------'}
% {Browse {N1 getSuccRef($)}#{N1 getId($)}}
% {Browse {N2 getSuccRef($)}#{N2 getId($)}}
% {Browse {N3 getSuccRef($)}#{N3 getId($)}}


% DHT Test
{N1 put(url bar)}
{Browse {N1 get(url $)}}

% commit and abort test
local P S in
   P={NewPort S}
   {Browse S}
   {N1 executeTransaction(
	  proc {$ TM}
	     {TM commit}
	  end
	     P paxos)}
end




% Merge
declare
fun {Merge O N}
   nil
end


% Transaction test
declare
Type=paxos
Value=newpage
proc {MakeSubmit Url NewPage ?MergedPage ?Transaction}
   Transaction =
   proc {$ TM}
      OldPage in
      {TM read(Url OldPage)}
      MergedPage={Merge OldPage NewPage}
      {TM write(Url MergedPage)}
      if MergedPage == nil then
	 {TM abort}
      else
	 {TM commit}
      end
   end
end
proc {MakeRefresh Url ?CurrentPage ?Transaction}
   Transaction =
   proc {$ TM}
      {TM read(Url CurrentPage)}
   end
end
proc {Submit Node Url NewPage ?Success}
   Result
   Client={NewPort Result}
   T
   MergedPage
in
   {MakeSubmit Url NewPage MergedPage T}
   {Node executeTransaction(T Client Type)}
   if MergedPage == nil then  Success=false else Success=true end
end
proc {Refresh Node Url ?CurrentPage}
   Result
   Client={NewPort Result}
   T
in
   {MakeRefresh Url CurrentPage T}
   {Node executeTransaction(T Client Type)}
end

{Browse {Refresh N3 url1}}
{Browse {Submit N2 url1 bar}}
{Browse {Refresh N1 url1}}








