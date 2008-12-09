functor
import
   System
   QTk at 'x-oz://system/wp/QTk.ozf'
   Application
   Connection
   P2PS at 'p2ps/trunk/P2PSNode.ozf'
export
   newring:NewRing
define
   fun {NewRing Type}
      N1={P2PS.newP2PSNode args(dist:Type transactions:true)}
      N2={P2PS.newP2PSNode args(dist:Type transactions:true)}
      N3={P2PS.newP2PSNode args(dist:Type transactions:true)}
      N4={P2PS.newP2PSNode args(dist:Type transactions:true)}
      N5={P2PS.newP2PSNode args(dist:Type transactions:true)}
   in
      {N2 join(RingRef)}
      {N3 join(RingRef)}
      {N4 join(RingRef)}
      {N5 join(RingRef)}
      {N1 getRingRef($)}
   end
   RingRef R
   Desc=message(aspect:200
		init:"The ring is running"
		handle:_
		return:R
	       )
in
   RingRef={NewRing dss}
   % UI to show that the ring is initialized

   {{QTk.build td(Desc)} show}
    % Output on the command line the reference to the ring
   {System.show {Connection.offerMany RingRef}}
   
   {Wait R} % R will be binded when the window is closed
   {Application.exit 0}
end