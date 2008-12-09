% Page Model
declare
EmptyPage=page(version:1)
SingleParagraph=page(version:1 highestposition:1 1:1
		     content:content(
				count:1
				1:paragraph(version:1 content:"It was a dark and stormy night.")))
TwoParagraphs=page(version:1 highestposition:2 1:1 2:2
		   content:content(
			      count:2
			      1:paragraph(version:1 content:"It was a dark and stormy night.")
			      2:paragraph(version:1 content:"Joe had never seen such a beautiful lady.")))

{Browse  {Adjoin r1(r2:content(1:test)) r1(r2:content(2:test2))}}

declare
fun {PosInsert Ls Position Value}
   case Ls
   of (Ind#V)|Lr then
      if Ind < Position then
	 (Ind#V)|{PosInsert Lr Position Value}
      elseif Ind == Position then
	 (Position#Value)|(Ind+1#V)|{PosInsert Lr Position nil}
      else
	 (Ind+1#V)|{PosInsert Lr Position Value}
      end
   [] nil then
      if Value == nil then nil else (Position#Value)|nil end
   end
end
fun {PosDelete Ls Position}
   case Ls
   of (Ind#V)|Lr then
      if Ind < Position then
	 (Ind#V)|{PosDelete Lr Position}
      elseif Ind == Position then
	 {PosDelete Lr Position}
      else
	 (Ind-1#V)|{PosDelete Lr Position}
      end
   [] nil then nil
   end
end
fun {ParagraphRefList Page}
   {Record.toListInd {Record.filterInd Page fun {$ I X} {IsNumber I} end}}
end
fun {PagePositions Ls}
   {List.toRecord page Ls}
end
fun {Squeleton Page}
   {Record.filterInd Page fun {$ I X} {Not {IsNumber I}} end}
end
%{Browse {PosDelete {ParagraphRefList TwoParagraphs} 1}}
%{Browse {Squeleton TwoParagraphs}}



declare
% This operation always succeed because it doesn't not modify existing content
fun {Add Page Position Paragraph}
   % Update various fields
   UpdatedCount={AdjoinAt Page.content count Page.content.count+1}
   UpdatedContent={AdjoinAt UpdatedCount Page.content.count+1 Paragraph}
   UpdatedPagePositions={AdjoinAt Page highestposition Page.highestposition+1}
   NewPage={AdjoinAt UpdatedPagePositions content UpdatedContent}
in
   if Page.highestposition >= Position then
      % Insert the content in the middle of the page
      {Adjoin NewPage
       {PagePositions
	{PosInsert
	 {ParagraphRefList UpdatedPagePositions}
	Position Page.content.count+1}}}
   else
      % Insert the content at the end of the page 
       {AdjoinAt NewPage NewPage.highestposition Page.content.count+1}
   end
end
{Browse SingleParagraph}
%{Browse {Add SingleParagraph 2 paragraph(version:1 content:"Joe had never seen such a beautiful lady.")}}
%{Browse {Add SingleParagraph 1 paragraph(version:1 content:"Joe had never seen such a beautiful lady.")}}
% This operation only succeed if the new paragraph has the correct version number
fun {Update Page Position NewParagraph}
   Current=Page.content.(Page.Position)
in
   % Only do it if the modification is being done on the most recent version
   if Current.version + 1 == NewParagraph.version andthen
      Current.content \= NewParagraph.content then NewContent
   in
      % Update the paragraph with the new one
      NewContent={AdjoinAt Page.content Page.Position NewParagraph}
      % Return the new page
      {AdjoinAt Page content NewContent}
   else
      % Return modification not possible
      nil
   end
end
%{Browse {Update SingleParagraph 1 paragraph(version:2 content:"It was a sunny and lovely day.")}}
fun {Delete Page Position OldParagraph}
   Current=Page.content.(Page.Position)
in
   % Delete the paragraph unless someone else edited it before
   if Current.version == OldParagraph.version then
      % Remove the paragraph from the content section
      NewContent={AdjoinAt Page.content Page.Position
		  {AdjoinAt Page.content.(Page.Position)
		   content nil}}
      NewPage={AdjoinAt
	       {AdjoinAt {Squeleton Page}
		highestposition Page.highestposition-1}
	       content NewContent}
   in
      % Adjust the paragraph positions in the page
      {Adjoin NewPage
       {PagePositions
	{PosDelete
	 {ParagraphRefList Page} Position}}}
   else
      % Return modification not possible
      nil
   end
end
{Browse {Delete TwoParagraphs 1 paragraph(version:1 content:"It was a dark and stormy night.")}}
% Manipulation of strings to determine actions to take
declare
fun {PosModif Original New}
   fun {Find Os Ns Pos}
      case Os#Ns
      of (O|Or)#(N|Nr) then
	 if O == N then {Find Or Nr Pos+1}
	 else
	    Pos
	 end
      [] nil#(N|Nr) then
	 Pos
      [] (O|Or)#nil then
	 Pos
      [] nil#nil then nil
      end
   end
in
   {Find Original New 1}
end
String1="12345678"
String2="12345abc678"
%{Browse {PosModif String1 String2}#({Length String1}-{PosModif {Reverse String1} {Reverse String2}}+1)}
fun {FromTo Ls Start End}
   if Start==1 andthen End==inf then
      Ls
   elseif Start == 1 then
      {List.take Ls End-Start+1}
   else
      case Ls of L|Lr then
	 if End == inf then
	    {FromTo Lr Start-1 inf}
	 else
	    {FromTo Lr Start-1 End-1}
	 end
      [] nil then nil
      end
   end
end
fun {Compare S1 S2}
   if S1 == S2 then same
   elseif {Length S1} > {Length S2} then
      % Maybe some characters have been deleted from S1
      Start={PosModif S1 S2}
      % To calculate the end of the modification remove the part matched so far
      % to avoid losing characters when the beginning and the ending
      % characters of the removed section are the same
      End={Length S1}-{PosModif {Reverse S1} {Reverse {FromTo S2 Start inf}}}+1
   in
      deleted('from':Start to:End 'of':S1 string:{FromTo S1 Start End})
   else
      % Maybe some characters have been inserted into S1
      Start={PosModif S1 S2}
      End={Length S2}-{PosModif {Reverse S1} {Reverse S2}}+1
   in
      added('at':Start string:{FromTo S2 Start End} 'of':S1)
   end
end
fun {ParagraphNb S Pos}
   fun {Iter S Pos ParagraphNb LastCR} 
      if Pos == 0 then ParagraphNb
      else PNb in
	 % Delay of 1 to make sure the paragraph number
	 % is incremented on the character after \n
	 if LastCR == true then
	    PNb=ParagraphNb+1
	 else
	    PNb=ParagraphNb
	 end
	 case S
	 of H|T then
	    if H == &\n then
	       {Iter T Pos-1 PNb true}
	    else {Iter T Pos-1 PNb false} end
	 [] nil then
	    ParagraphNb
	 end
      end
   end
in
   {Iter S Pos 1 false}
end
fun {Paragraph S Nb}
   {List.nth {Split S &\n} Nb}
end   
% Reimplementation of splitting function to have the following desired
% behavior, like in python with split
% {Split "123" &\n} -> ["123"]
% {Split "\n123" &\n} -> [nil "123"]
% {Split "\n123\n" &\n} -> [nil "123" nil]
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
% Still buggy, doesn't behave correctly
fun {Modifications S1 S2}
   CurrentParagraphNb={NewCell 1}
   Modifs={NewCell nil}
   ParagraphsModified
in
   case {Compare S1 S2}
   of deleted('from':Start to:End 'of':S1 string:D) then
      CurrentParagraphNb:={ParagraphNb S1 Start}
      LastParagraphNb={ParagraphNb S1 End}
      ParagraphsModified={Split D &\n}
   in
      for P in ParagraphsModified do
	 if P == {Paragraph S1 @CurrentParagraphNb} then
	    Modifs:={Append @Modifs [delete(pos:@CurrentParagraphNb)]}
	 else
	    Modifs:={Append @Modifs [update(pos:@CurrentParagraphNb
					    content:{Paragraph S2 @CurrentParagraphNb})]}
	 end
	 CurrentParagraphNb:=@CurrentParagraphNb+1
      end
      @Modifs
   [] added('at':Start string:A 'of':S1) then
      nil
   [] same then
      nil
   end
end

% 
{Browse {Modifications "11\n22\n33\n44\n" "11\n22\n33\n44\n"}} % No changes     
{Browse {Modifications "11\n22\n33\n44\n" "1\n22\n33\n44\n"}}  % Update to first
{Browse {Modifications "11\n22\n33\n44\n" "\n22\n33\n44\n"}}   % Delete first
{Browse {Modifications "11\n22\n33\n44\n" "122\n33\n44\n"}}    % Update to first, delete 2
{Browse {Modifications "11\n22\n33\n44\n" "1122\n33\n44\n"}}   % Update to first, delete 2
{Browse {Modifications "11\n22\n33\n44\n" "22\n33\n44\n"}}     % Delete first
{Browse {Modifications "11\n22\n33\n44\n" "2\n33\n44\n"}}      % Delete first, update 2
{Browse {Modifications "11\n22\n33\n44\n" "11\n2\n33\n44\n"}}  % Update 2
{Browse {Modifications "11\n22\n33\n44\n" "11\n\n33\n44\n"}}   % Delete 2
{Browse {Modifications "11\n22\n33\n44\n" "11\n33\n44\n"}}     % Delete 2
{Browse {Modifications "11\n22\n33\n44\n" "1133\n44\n"}}       % Update 1 Delete 2 Delete 3
{Browse {Modifications "11\n22\n33\n44\n" "11\n22\n33\n4\n"}}  % Update 4
{Browse {Modifications "11\n22\n33\n44\n" "11\n22\n33\n\n"}}   % Delete 4
{Browse {Modifications "11\n22\n33\n44\n" "11\n22\n33\n"}}     % Delete 4

{Browse {Compare "It was a dark\n and stormy night.\n" "It was my night.\n"}}
{Browse {FromTo "It was a dark and stormy night." 15 24}}

{Browse {Length " a "}}
{Browse {Split [10] &\n}}









%{Browse TwoParagraphs}
%{Browse {Delete TwoParagraphs 1 paragraph(version:1 content:"It was a dark and stormy night.")}}
fun {Diff Page1 Page2}
   Page1
end
fun {Apply Page Changes}
   Page
end
fun 
fun {Render Page}
   "hello"
end
fun {Parse String}
   page()
end
   

