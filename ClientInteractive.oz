declare
[P2PS Transactions RingInit Page]={Module.link ["bin/p2ps/trunk/P2PSNode.ozf" "bin/Transactions.ozf" "bin/RingInit.ozf" "bin/Page.ozf"]}
N={P2PS.newP2PSNode args(dist:dss transactions:true)}
fun {Take FN}
   {Connection.take {Pickle.load FN}}
end

declare
RingRef={RingInit.newring dss}
{Browse RingRef}

declare
RingRef={Take './ringref.txt'}
{Browse RingRef}

{N join(RingRef)}

{Browse {N getSuccRef($)}#{N getId($)}}
{Browse RingRef}

declare
% Testing concurrent modifications
O={Transactions.refresh N url}
C1={Page.update O 1 "new content"}
C2={Page.update O 1 "new content2"}

{Browse {Transactions.refresh N url}}
{Browse {Page.tostring {Transactions.refresh N url}}}

{Browse {Transactions.submit N url C1}}
{Browse {Transactions.submit N url C2}}

declare
% New splitting function to have paragraphs delimited by a double \n
fun {Split S Del}
   Tokens={NewCell nil}
   Token={NewCell nil}
   fun {Iter S}
      case S of nil then
	 Tokens:={Reverse @Token}|@Tokens
	 {Reverse @Tokens}
      [] S|Sr then
	 if S == Del then
	    Tokens:={Reverse @Token}|@Tokens
	    Token:=nil
	    {Iter Sr}
	 else
	    Token:=S|@Token
	    {Iter Sr}
	 end
      end
   end
in
   {Iter S}
end
