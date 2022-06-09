<%@ page language="java" contentType="text/html; charset=EUC-KR"
    pageEncoding="EUC-KR"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="EUC-KR">
<title>Insert title here</title>
</head>
<body>
	<a id="goList">리스트가기</a>
</body>
<script src="https://code.jquery.com/jquery-1.12.4.min.js"></script>
<script type="text/javascript">
	
	$('#goList').on('click', () => {
		location.assign('/board/goList')
	})
	$('#goList').trigger('click')
	
	/*
	$( "#foo" ).on( "click", function() {
	  alert( $( this ).text() );
	});
	$( "#foo" ).trigger( "click" );
	*/
</script>
</html>