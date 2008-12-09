functor
import
   Connection
   QTk at 'x-oz://system/wp/QTk.ozf'
   P2PS  at 'p2ps/trunk/P2PSNode.ozf'
   System
define
   OzTicket={NewCell nil}
   RingRef
   % Obtain the reference to the ring
   local
   E R
   Desc=td(entry(init:"Enter Ring Reference here"
	      handle:E
	      return:R
		 action:proc{$} OzTicket:={String.toAtom {E get($)}} end)
	   button(text:"Connect"
		  return:_
		  action:proc{$}
			    {E set({Append "Connecting to: " {E get($)}})}
			    RingRef={Connection.take @OzTicket}
			    {Window close}
			 end ))
   in
      Window={QTk.build Desc}
      {Window show}
      {Wait R}
   end

   % Initialize node and join the ring
   N={P2PS.newP2PSNode args(dist:dss transactions:true)}
   {N join(RingRef)}

   % Start the main client window
   {System.show {String.toAtom {N getId($)}}}
end
