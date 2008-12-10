%The Logical page representation
functor
import
export
   newpage:NewPage
   add:Add
   update:Update
   delete:Delete
   merge:Merge
   updatefromstring:UpdateFromString
   tostring:ToString
define
% Helper functions
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
   %
   fun {NewPage}
      page(version:1 highestposition:1 1:1
	   content:
	      content(count:1
		      1:paragraph(version:1
				  content:"To be filled.")))
   end
   fun {Set Paragraph Field Value}
      {AdjoinAt Paragraph Field Value}
   end
   fun {ReversePosLookup Page ParID}
      Pos={NewCell nil}
   in
      for P#PID in {ParagraphRefList Page} do
	 if PID == ParID then
	    Pos:=P
	 end
      end
      @Pos
   end
% This operation always succeed because it doesn't not modify existing content
   fun {Add Page Position Content}
   % Update various fields
      UpdatedCount={AdjoinAt Page.content count Page.content.count+1}
      UpdatedContent={AdjoinAt UpdatedCount Page.content.count+1
		      paragraph(version:1 content:Content)}
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
   fun {Update Page Position Content}
      Current=Page.content.(Page.Position)
      NewContent
   in
      % Update the paragraph with the new one
      NewContent={Set Page.content Page.Position
		  {Set {Set Current version Current.version+1}
		   content Content}}
      % Return the new page
      {Set Page content NewContent}
   end
   fun {Delete Page Position}
      Current=Page.content.(Page.Position)
      % Remove the paragraph from the content section (set content to nil)
      NewContent={Set Page.content Page.Position
		  {Set {Set Current version Current.version+1}
		   content nil}}
      NewPage={Set
	       {Set {Squeleton Page}
		highestposition Page.highestposition-1}
	       content NewContent}
   in
      % Adjust the paragraph positions in the page
      {Adjoin NewPage
       {PagePositions
	{PosDelete
	 {ParagraphRefList Page} Position}}}
   end
   % Simplified version for the merge algorithm
   fun {Merge CurrentPage NewPage}
      MergedPage={NewCell CurrentPage}
   % Increment the page version by 1
      MergedPage:={Set @MergedPage  version
		   {Max CurrentPage.version NewPage.version} + 1}
      Valid={NewCell true}
      fun {SetPar Page Pos Par}
	 {Set Page content {Set Page.content Pos Par}}
      end
   in
      for P in 1..{Max CurrentPage.content.count NewPage.content.count} do
	 CPar={CondSelect CurrentPage.content P nil}
	 NPar={CondSelect NewPage.content P nil}
      in
      % Paragraph added on newer
	 if CPar == nil then
	    MergedPage:={Add @MergedPage {ReversePosLookup NewPage P} NPar.content}
      % Paragraph added on older
	 elseif NPar == nil then
	 % Addition on a paragraph only supported on newer page
	    Valid:=false
      % No modifications
	 elseif CPar.version == NPar.version
	    andthen CPar.content == NPar.content then
	    skip % Keep the current paragraph
      % Modification on older
	 elseif CPar.version == NPar.version + 1 then
	    if CPar.content \= nil then
	       MergedPage:={SetPar @MergedPage P CPar}
	    else
	    % Deletion of a paragraph only accepted on newer
	       Valid:=false
	    end
      % Modification on newer
	 elseif CPar.version == NPar.version - 1 then
	    if NPar.content \= nil then
	       MergedPage:={SetPar @MergedPage P NPar}
	    else
	    % Delete from older version
	       MergedPage:={Delete @MergedPage {ReversePosLookup CurrentPage P}}
	    end
	 else
	    Valid:=false
	 end
      end
   % Only return the merged page if every modifications were successful
      if @Valid == true then
	 @MergedPage
      else
	 nil
      end
   end
   fun {ToString Page}
      String={NewCell ""}
   in
      for P in 1..Page.highestposition do Par=Page.content.(Page.P) in
	 String:={Append {Append @String Par.content} "\n\n"}
      end
      @String
   end
% Update page from string modification
   fun {UpdateFromString Page NewString}
      Pars={List.filter {String.tokens NewString &\n} fun {$ X} X \= nil end}
      NewPage={NewCell Page}
   in
   % Only updates have occured
      if {Length Pars} == Page.highestposition then Pos={NewCell 1} in
	 for P in Pars do CurrentPar=Page.content.(Page.@Pos).content in
	    if P \= CurrentPar then
	       NewPage:={Update @NewPage @Pos P}
	    end
	    Pos:=@Pos+1
	 end
	 @NewPage
   % One paragraph has been deleted
      elseif {Length Pars} == Page.highestposition - 1 then
	 Deleted={NewCell false} Pos={NewCell 1} in
	 for P in Pars do
	    CurrentPar=Page.content.(Page.@Pos).content
	    NextPar=Page.content.(Page.(@Pos+1)).content
	 in
	    if P \= CurrentPar andthen P == NextPar then
	       NewPage:={Delete @NewPage @Pos}
	       Deleted:=true
	    end
	    Pos:=@Pos+1
	 end
	 if @Deleted == false then
	    % Delete the last paragraph
	    {Delete @NewPage Page.highestposition}
	 else
	    @NewPage
	 end
   % One paragraph has been added
      elseif {Length Pars} == Page.highestposition + 1 then
	 Added={NewCell false}
	 NewPar={NewCell {List.nth Pars 1}}
	 NewNextPar={NewCell {List.nth Pars 2}}
	 Last={Length Pars} 
      in
	 for Pos in 1..Page.highestposition do
	    CurrentPar=Page.content.(Page.Pos).content
	 in
	    if CurrentPar \= @NewPar andthen CurrentPar == @NewNextPar then
	       NewPage:={Add @NewPage Pos @NewPar}
	       Added:=true
	    end
	    NewPar:=@NewNextPar
	    if Pos+2 < Last then
	       NewNextPar:={List.nth Pars Pos+2}
	    else
	       NewNextPar:=nil
	    end
	 end
	 if @Added \= true then
	 % Add the last paragraph
	    NewPage:={Add @NewPage Page.highestposition+1 @NewPar}
	 end
	 @NewPage
   % Do not support addition or deletion of more than one paragraph
      else
	 nil
      end
   end

% % Manipulation of strings to determine actions to take
%    fun {PosModif Original New}
%       fun {Find Os Ns Pos}
% 	 case Os#Ns
% 	 of (O|Or)#(N|Nr) then
% 	    if O == N then {Find Or Nr Pos+1}
% 	    else
% 	       Pos
% 	    end
% 	 [] nil#(N|Nr) then
% 	    Pos
% 	 [] (O|Or)#nil then
% 	    Pos
% 	 [] nil#nil then nil
% 	 end
%       end
%    in
%       {Find Original New 1}
%    end
%    fun {FromTo Ls Start End}
%       if Start==1 andthen End==inf then
% 	 Ls
%       elseif Start == 1 then
% 	 {List.take Ls End-Start+1}
%       else
% 	 case Ls of L|Lr then
% 	    if End == inf then
% 	       {FromTo Lr Start-1 inf}
% 	    else
% 	       {FromTo Lr Start-1 End-1}
% 	    end
% 	 [] nil then nil
% 	 end
%       end
%    end
%    fun {Compare S1 S2}
%       if S1 == S2 then same
%       elseif {Length S1} > {Length S2} then
%       % Maybe some characters have been deleted from S1
% 	 Start={PosModif S1 S2}
%       % To calculate the end of the modification remove the part matched so far
%       % to avoid losing characters when the beginning and the ending
%       % characters of the removed section are the same
% 	 End={Length S1}-{PosModif {Reverse S1} {Reverse {FromTo S2 Start inf}}}+1
%       in
% 	 deleted('from':Start to:End 'of':S1 string:{FromTo S1 Start End})
%       else
%       % Maybe some characters have been inserted into S1
% 	 Start={PosModif S1 S2}
% 	 End={Length S2}-{PosModif {Reverse S1} {Reverse S2}}+1
%       in
% 	 added('at':Start string:{FromTo S2 Start End} 'of':S1)
%       end
%    end
%    fun {ParagraphNb S Pos}
%       fun {Iter S Pos ParagraphNb LastCR} 
% 	 if Pos == 0 then ParagraphNb
% 	 else PNb in
% 	 % Delay of 1 to make sure the paragraph number
% 	 % is incremented on the character after \n
% 	    if LastCR == true then
% 	       PNb=ParagraphNb+1
% 	    else
% 	       PNb=ParagraphNb
% 	    end
% 	    case S
% 	    of H|T then
% 	       if H == &\n then
% 		  {Iter T Pos-1 PNb true}
% 	       else {Iter T Pos-1 PNb false} end
% 	    [] nil then
% 	       ParagraphNb
% 	    end
% 	 end
%       end
%    in
%       {Iter S Pos 1 false}
%    end
%    fun {Paragraph S Nb}
%       {List.nth {Split S &\n} Nb}
%    end   
% % Reimplementation of splitting function to have the following desired
% % behavior, like in python with split
% % {Split "123" &\n} -> ["123"]
% % {Split "\n123" &\n} -> [nil "123"]
% % {Split "\n123\n" &\n} -> [nil "123" nil]
%    fun {Split S Del}
%       Tokens={NewCell nil}
%       Token={NewCell nil}
%       fun {Iter S}
% 	 case S of nil then
% 	    Tokens:={Reverse @Token}|@Tokens
% 	    {Reverse @Tokens}
% 	 [] S|Sr then
% 	    if S == Del then
% 	       Tokens:={Reverse @Token}|@Tokens
% 	       Token:=nil
% 	       {Iter Sr}
% 	    else
% 	       Token:=S|@Token
% 	       {Iter Sr}
% 	    end
% 	 end
%       end
%    in
%       {Iter S}
%    end
% % Still buggy, doesn't behave correctly
%    fun {Modifications S1 S2}
%       CurrentParagraphNb={NewCell 1}
%       Modifs={NewCell nil}
%       ParagraphsModified
%    in
%       case {Compare S1 S2}
%       of deleted('from':Start to:End 'of':S1 string:D) then
% 	 CurrentParagraphNb:={ParagraphNb S1 Start}
% 	 LastParagraphNb={ParagraphNb S1 End}
% 	 ParagraphsModified={Split D &\n}
%       in
% 	 for P in ParagraphsModified do
% 	    if P == {Paragraph S1 @CurrentParagraphNb} then
% 	       Modifs:={Append @Modifs [delete(pos:@CurrentParagraphNb)]}
% 	    else
% 	       Modifs:={Append @Modifs [update(pos:@CurrentParagraphNb
% 					       content:{Paragraph S2 @CurrentParagraphNb})]}
% 	    end
% 	    CurrentParagraphNb:=@CurrentParagraphNb+1
% 	 end
% 	 @Modifs
%       [] added('at':Start string:A 'of':S1) then
% 	 nil
%       [] same then
% 	 nil
%       end
%    end
end
