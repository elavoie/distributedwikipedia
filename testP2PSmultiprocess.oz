declare
[P2PS]={Module.link ["/Users/erick/Desktop/p2ps-scm-2008-11-24/trunk/P2PSNode.ozf"]}

declare
proc {Offer T FN}
   {Pickle.save {Connection.offerMany T} FN}
end
fun {Take FN}
   {Connection.take {Pickle.load FN}}
end

declare
N1={P2PS.newP2PSNode args(dist:dss)}

{Offer {N1 getRingRef($)} '/Users/erick/Desktop/ringref.txt'}


{Browse '-----Verifying ring structure------'}
{Browse {N1 getId($)}#{N1 getSuccRef($)}}
