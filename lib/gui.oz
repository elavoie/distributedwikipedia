functor
import
	Pickle
	Connection
	P2PS
	System
	QTk at 'x-oz://system/wp/QTk.ozf'
	Transaction
	Application
define
	Win		% the window
	DefaultTicketFile = "default_connection.ticket"
	OzTicket = {NewCell nil} % ticket to the server
	RingRef		%reference to the server
	Node		%the client node
	UrlHandle
	Url	= {NewCell nil} %the url
	PageHandle
	GuiQuit		%binds when the application quits
	proc {ServerConnect}	%when the user clicks on connect
		OzTicket := {String.toAtom{UrlHandle get($)}}
		RingRef = {Connection.take @OzTicket}
		{System.show @OzTicket}
	end
	proc {GoToPage}	%when the user clicks on go to page
		{System.show goToPage}
	end
	proc {Submit} %when the user clicks on submit
		{System.show submit}
	end
	proc {PageChange} %when the user changes the page
		{System.show pageChanged} 
	end
	proc {Refresh} %when the user refresh the page
		{System.show refresh}
	end
	proc {Save} %when the user saves the page
		{System.show save}
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
	Win = {QTk.build D}
	{Win show}
	{Wait GuiQuit}
	{Application.exit 0}
end
