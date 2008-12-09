declare
[P2PS Transactions RingInit Page]={Module.link ["bin/p2ps/trunk/P2PSNode.ozf" "bin/Transactions.ozf" "bin/RingInit.ozf" "bin/Page.ozf"]}
N={P2PS.newP2PSNode args(dist:dss transactions:true)}

declare
RingRef={RingInit.newring dss}
{Browse RingRef}

{N join(RingRef)}

{Browse {N getSuccRef($)}#{N getId($)}}
{Browse RingRef}


{Browse {Transactions.submit N url {Page.update {Transactions.refresh N url}  1 "new content"}}}
{Browse {Transactions.refresh N url}}

declare
V={Refresh N url}
{Browse V}

{Browse {Value.status V}}

declare
Type=paxos
proc {MakeSubmit Url NewPage ?Transaction}
   MergedPage
in
   Transaction =
   proc {$ TM}
      OldPage Temp in
      {TM read(Url Temp)}
      if {Value.status Temp} == failed then
	 OldPage={Page.newpage}
	 {TM write(Url OldPage)}
      else
	 OldPage=Temp
      end
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
   proc {$ TM} Temp in
      {TM read(Url Temp)}
      if {Value.status Temp} == failed then
	 CurrentPage={Page.newpage}
	 {TM write(Url CurrentPage)}
      else
	 CurrentPage=Temp
      end
      {TM commit}
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