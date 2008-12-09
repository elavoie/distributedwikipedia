functor
import
   Page at 'bin/Page.ozf'
export
   submit:Submit
   refresh:Refresh
define
   Type=paxos
   proc {MakeSubmit Url NewPage ?Transaction}
      MergedPage
   in
      Transaction =
      proc {$ TM}
	 OldPage in
	 {TM read(Url OldPage)}
	 MergedPage={Page.merge OldPage NewPage}
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
   in
      {MakeSubmit Url NewPage T}
      {Node executeTransaction(T Client Type)}
      if Result.1 == commit then Success=true else Success=false end
   end
   proc {Refresh Node Url ?CurrentPage}
      Result
      Client={NewPort Result}
      T
   in
      {MakeRefresh Url CurrentPage T}
      {Node executeTransaction(T Client Type)}
      Result.1=commit
   end
end