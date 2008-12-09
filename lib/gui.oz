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
	UrlHandle	
	PageHandle
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
	proc {ServerConnect}	%when the user clicks on connect
		{System.show serverconnect_start}
		OzTicket := {String.toAtom{UrlHandle get($)}}
		{System.show @OzTicket}
		%RingRef = {Connection.take @OzTicket}

		Node = {P2PS.newP2PSNode args(dist:dss transactions:true)}
		{Node join(RingRef)}
		{System.show {Node getId($)}#{Node getSuccRef($)}}
		CurrentPage := {Transactions.refresh Node home}
		{UrlHandle set( {Atom.toString home} )}
		{SetPageText}
		{System.show serverconnect_end}
	end
	proc {GoToPage}	%when the user clicks on go to page
		CurrentPage := {Transactions.refresh Node {GetUrl} }
		{SetPageText}
	end
	proc {Submit} %when the user clicks on submit
		Result = {Transactions.submit Node {GetUrl} @CurrentPage}
		%TODO (renvoie true ou false ) Popup si ca marche pas.
		in
		{GoToPage}
	end
	proc {PageChange} %when the user changes the page
		%CurrentPage := {Page.updatefromstring @CurrentPage {GetPageText}}
		skip
	end
	proc {Refresh} %when the user refresh the page
		{GoToPage}
	end
	proc {Save} %when the user saves the page
		{System.show save}
		CurrentPage := {Page.updatefromstring @CurrentPage {GetPageText}}
	end
	
D=td(	return:GuiQuit
	lr( 	
		glue:nwe
		entry(
			handle:UrlHandle
			glue:we
			init:{Pickle.load DefaultTicketFile} 
			)
		button(	
			text:"Go to page" 
			glue:ne		
			action: GoToPage
			
			)
		button(
			text:"Connect to server"
			glue:ne
			action:ServerConnect)
		
	)
	text(	
		handle:PageHandle
		glue:nswe
		tdscrollbar:true
		bg:white
		action:PageChange)
	lr(	
		glue:swe
		button(
			text:"Save changes"
			glue:swe
			action:Save)
		button(
			text:"Refresh page"
			glue:swe
			action:Refresh)
		button(
			text:"Submit saved changes"
			glue:swe
			action:Submit)
		button(
			text:"Exit"
			glue:swe
			action:toplevel#close	)
			
	)
)
in	
	
	%{Offer {RingInit.newring dss} DefaultTicketFile} 
	RingRef = {RingInit.newring dss}
	Win = {QTk.build D}
	{Win show}
	{Wait GuiQuit}
	{Application.exit 0}
end
