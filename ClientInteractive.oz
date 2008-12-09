declare
[P2PS Transactions]={Module.link ["/Users/erick/Desktop/DistributedWikipedia/p2ps/trunk/P2PSNode.ozf" "/Users/erick/Desktop/DistributedWikipedia/Transactions.ozf"]}
N={P2PS.newP2PSNode args(dist:dss transactions:true)}


declare
RingRef={Connection.take 'oz-ticket://127.0.0.1:9000/h4655237#29'}
{N join(RingRef)}

{Browse {N getSuccRef($)}}
{Browse N}

{Browse Transactions.refresh}


thread {Delay {OS.rand} mod 100} {Browse {Transactions.submit N url page}} end
thread {Delay {OS.rand} mod 100} {Browse {Transactions.submit N url page2}} end

{Browse {Transactions.refresh N url}}