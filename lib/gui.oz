functor
import
	Pickle
	Connection
	P2PS at 'p2ps/trunk/P2PSNode.ozf'
	System
	QTk at 'x-oz://system/wp/QTk.ozf'
	Application
	Page at 'Page.ozf' 
	RingInit at 'RingInit.ozf'
	Transactions at 'Transactions.ozf'
define
	Win		% the window
	DefaultTicketFile = "default_connection.ticket"
	OzTicket = {NewCell nil} % ticket to the server
	RingRef		%reference to the server
	Node		%the client node
	
	UrlHandle	%widget handles
	PageHandle
	StatusHandle
	HostButtonHandle
	GoButtonHandle
	ConnectButtonHandle
	SaveButtonHandle
	SubmitButtonHandle
	RefreshButtonHandle
	
	GuiQuit		%binds when the application quits
	CurrentPage = {NewCell {Page.newpage}}	%the current symbolic page
	proc {Offer T FN}
   		{Pickle.save {Connection.offerMany T} FN}
	end
	proc {SetPageText}
		{PageHandle set( {Page.tostring @CurrentPage} )}
	end
	fun {GetPageText}
		{PageHandle get($)}
	end
	fun {GetUrl}
		{String.toAtom {UrlHandle get($)}}
	end
	proc {SetUrl S}
		{UrlHandle set(S)}
	end
	proc {SetButtonConnected}
		{PageHandle set(state:normal)}
		{HostButtonHandle set(state:disabled)}
		{GoButtonHandle set(state:normal)}
		{ConnectButtonHandle set(state:disabled)}
		{RefreshButtonHandle set(state:normal)}
	end
	proc {SetStatusOnline}
		{StatusHandle set("Online")}
		{StatusHandle set(bg:c(0 255 128))}
	end
	proc {SetStatusUnsaved}
		{StatusHandle set("Page Edited, Please Save changes !")}
		{StatusHandle set(bg:c(255 128 0))}
	end
	proc {SetStatusComit}
		{StatusHandle set("Please Submit your changes")}
		{StatusHandle set(bg:c(255 255 0))}
	end
	proc {SetStatusComitError}
		{StatusHandle set("Could not submit, changes lost")}
		{StatusHandle set(bg:c(255 0 0 ))}
	end
	proc {SetStatusSaveError}
		{StatusHandle set("Could not understand text changes. Reverting")}
		{StatusHandle set(bg:c(255 0 0 ))}
	end
	proc {SetStatusComitSuccess}
		{StatusHandle set("Changes have been submitted")}
		{StatusHandle set(bg:c(0 255 128))}
	end
	proc {SetStatusNewServer}
		{StatusHandle set(@OzTicket)}
		{StatusHandle set(bg:c(0 128 255))}
	end
	proc {ServerConnect}	%when the user clicks on connect
		{System.show serverconnect_start}
		OzTicket := {String.toAtom {UrlHandle get($)}}
		{System.show gotOzTicket}
		RingRef = {Connection.take @OzTicket}
		{System.show gotRingRef}
		Node = {P2PS.newP2PSNode args(dist:dss transactions:true)}
		{System.show gotNode}
		{Node join(RingRef)}
		{System.show nodeJoined}
		{System.show {Node getId($)}#{Node getSuccRef($)}}
		CurrentPage := {Transactions.refresh Node home}
		{System.show pageRefreshed}
		{SetButtonConnected}
		{UrlHandle set( {Atom.toString home} )}
		{SetPageText}
		{SetStatusOnline}
		{System.show serverconnect_end}
	end		
	proc {ServerHost}	%when the user clicks on server host
		{System.show serverhost_start}
		RingRef = {RingInit.newring dss}
		OzTicket := {Connection.offerMany RingRef}
		{Pickle.save @OzTicket DefaultTicketFile}
		{SetUrl @OzTicket}
		%	server created.
		Node = {P2PS.newP2PSNode args(dist:dss transactions:true)}
		{Node join(RingRef)}
		{SetButtonConnected}	%Must be before we refresh the page
		CurrentPage := {Transactions.refresh Node home}
		{System.show pageRefreshed}
		{UrlHandle set({Atom.toString home} )}
		{SetPageText}
		{SetStatusNewServer}

	end
	proc {GoToPage}	%when the user clicks on go to page
		CurrentPage := {Transactions.refresh Node {GetUrl} }
		{SetPageText}
		{SetStatusOnline}
	end
	proc {Submit} %when the user clicks on submit
		Result = {Transactions.submit Node {GetUrl} @CurrentPage}
		%TODO (renvoie true ou false ) Popup si ca marche pas.
		in
		{GoToPage}
		if(Result) then
			{SetStatusComitSuccess} 
		else 
			{SetStatusComitError}
		end
		{SubmitButtonHandle set(state:disabled)}
	end
	proc {PageChange} %when the user changes the page
		%CurrentPage := {Page.updatefromstring @CurrentPage {GetPageText}}
		{SetStatusUnsaved}
		{SaveButtonHandle set(state:normal)}
		{SubmitButtonHandle set(state:disabled)}
		skip
	end
	proc {Refresh} %when the user refresh the page
		{GoToPage}
		{SaveButtonHandle set(state:disabled)}
		{SubmitButtonHandle set(state:disabled)}
	end
	proc {Save} %when the user saves the page
		{System.show save}
		CurrentPage := {Page.updatefromstring @CurrentPage {GetPageText}}
		if @CurrentPage == nil then
			{System.show saveError}
			{Refresh}
			{SetStatusSaveError}
		else
			{SetStatusComit}
			{SaveButtonHandle set(state:disabled)}
			{SubmitButtonHandle set(state:normal)}
		end
	end
	
D=td(	return:GuiQuit
	lr( 	
		glue:nwe
		entry(
			handle:UrlHandle
			glue:we
			)
		button(	
			handle:GoButtonHandle
			text:"Go to page" 
			glue:ne		
			action: GoToPage
			state:disabled
			)
		button(
			handle:ConnectButtonHandle
			text:"Connect to server"
			glue:ne
			action:ServerConnect)
		button(
			handle:HostButtonHandle
			text:"Host server"
			glue:ne
			action:ServerHost)
		
	)
	text(	
		handle:PageHandle
		glue:nswe
		tdscrollbar:true
		bg:white
		action:PageChange
		state:disabled)
	lr(	
		glue:swe
		button(
			handle:SaveButtonHandle
			text:"Save changes"
			glue:swe
			action:Save
			state:disabled)
		button(
			handle:RefreshButtonHandle
			text:"Refresh page"
			glue:swe
			action:Refresh
			state:disabled)
		button(
			handle:SubmitButtonHandle
			text:"Submit saved changes"
			glue:swe
			action:Submit
			state:disabled)
		button(
			text:"Exit"
			glue:swe
			action:toplevel#close	)
		
	)
	entry(	
		handle:StatusHandle
		glue:swe
		init:"Please connect to a server"
		%state:disabled
		bg:c(255 128 0)
		)
)
in	
	
	%{Offer {RingInit.newring dss} DefaultTicketFile} 
	
	%{Pickle.save {Connection.offerMany {RingInit.newring dss}} DefaultTicketFile}
	
	%RingRef = {RingInit.newring dss}
	Win = {QTk.build D}
	{Win show}
	{SetUrl {Pickle.load DefaultTicketFile}}
	%{SetStatusOnline}
	{Wait GuiQuit}
	{Application.exit 0}
end
