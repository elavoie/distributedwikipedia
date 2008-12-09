functor
import
   RingInit at 'bin/RingInit.ozf'
   Connection
   Pickle
   QTk at 'x-oz://system/wp/QTk.ozf'
   Application
define
   proc {Offer T FN}
   {Pickle.save {Connection.offerMany T} FN}
   end
   RingRef={RingInit.newring dss}
   R
    Desc=message(aspect:200
 		init:"The ring is running"
 		handle:_
 		return:R
 	       )
in
    % UI to show that the ring is initialized
   {{QTk.build td(Desc)} show}
   {Offer RingRef './ringref.txt'}
   {Wait R} % R will be binded when the window is closed
   {Application.exit 0}
end