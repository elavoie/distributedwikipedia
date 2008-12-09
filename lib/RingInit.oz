functor
import
   System
   QTk at 'x-oz://system/wp/QTk.ozf'
   Application
   Connection
   P2PS at 'p2ps/trunk/P2PSNode.ozf'
export
define
   N1={P2PS.newP2PSNode args(dist:dss transactions:true)}
   N2={P2PS.newP2PSNode args(dist:dss transactions:true)}
   N3={P2PS.newP2PSNode args(dist:dss transactions:true)}
   N4={P2PS.newP2PSNode args(dist:dss transactions:true)}
   N5={P2PS.newP2PSNode args(dist:dss transactions:true)}
   RingRef={N1 getRingRef($)}
   {N2 join(RingRef)}
   {N3 join(RingRef)}
   {N4 join(RingRef)}
   {N5 join(RingRef)}
   % UI to show that the ring is initialized
   R
   Desc=message(aspect:200
		init:"The ring is running"
		handle:_
		return:R
	       )
   {{QTk.build td(Desc)} show}
    % Output on the command line the reference to the ring
   {System.show {Connection.offerMany RingRef}}
   
   {Wait R} % R will be binded when the window is closed
   {Application.exit 0}
end