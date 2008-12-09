functor
import
   P2PS at 'p2ps/trunk/P2PSNode.ozf'
export
   newring:NewRing
define
   proc {NewRing Type RingRef?}
      N1={P2PS.newP2PSNode args(dist:Type transactions:true)}
      N2={P2PS.newP2PSNode args(dist:Type transactions:true)}
      N3={P2PS.newP2PSNode args(dist:Type transactions:true)}
      N4={P2PS.newP2PSNode args(dist:Type transactions:true)}
      N5={P2PS.newP2PSNode args(dist:Type transactions:true)}
   in
      RingRef={N1 getRingRef($)}
      {N2 join(RingRef)}
      {N3 join(RingRef)}
      {N4 join(RingRef)}
      {N5 join(RingRef)}
   end
end