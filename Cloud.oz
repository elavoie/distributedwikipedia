functor
import
   RingInit at 'bin/RingInit.ozf'
   Connection
   Pickle
   QTk at 'x-oz://system/wp/QTk.ozf'
   Application
   System
define
   proc {Offer T FN}
   C = {Connection.offerMany T}
   in
   {Pickle.save C FN}
   {System.show C}
   {System.show test}
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
   {Offer RingRef './default_connection.ticket'}
   {Wait R} % R will be binded when the window is closed
   {Application.exit 0}
end
