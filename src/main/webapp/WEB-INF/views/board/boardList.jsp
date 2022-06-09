<%@ page language="java" contentType="text/html; charset=EUC-KR"
    pageEncoding="EUC-KR"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt"%>    
<!DOCTYPE html>
<html>
<head>
<meta charset="EUC-KR">
<title>Insert title here</title>
</head>
<body>
	<span>
		 총 <c:out value="${ boardList.Total }" />개
	</span>
	<table>
		<colgroup>
			<col width="30px" />
			<col width="100px" />
			<col width="250px" />
			<col width="150px" />
			<col width="150px" />
			<col width="150px" />
			<col width="150px" />
		</colgroup>
		<thead>
			<tr>
				<th><input type="checkbox" id="allCheck"></th>
				<th>번호</th>
				<th>제목</th>
				<th>작성자</th>
				<th>등록일</th>
				<th>등록 시간</th>
				<th>조회수</th>
			</tr>
		</thead>
		<tbody>
			<c:forEach var="board" items="${ boardList.Data }">
				<fmt:parseDate value="${ board.insertTime }" pattern="yyyy-MM-dd'T'HH:mm" var="parseDateTime" type="both" />
				<tr>
					<td>
						<input type="checkbox" name="rowCheck" data-idx='<c:out value="${ board.idx }" />'>
					</td>
					<td>
						<c:out value="${ board.num }" />
					</td>
					<td class="title">
						<c:choose>
							<c:when test = "${ board.depth == 1 }">
								<!-- 원글 -->
								<c:choose>
									<c:when test="${ board.noticeYn eq true }">
										<a href="#" class="boardTitle" data-idx='<c:out value="${ board.idx }" />' data-secret-yn='<c:out value="${ board.secretYn }" />' data-notice-yn='<c:out value="${ board.noticeYn }" />' >
											#공지# <c:out value="${ board.title }" />
										</a>
									</c:when>
									<c:otherwise>
										<c:choose>
											<c:when test = "${ board.secretYn eq true }">
												<a href="#" class="boardTitle" data-idx='<c:out value="${ board.idx }" />' data-secret-yn='<c:out value="${ board.secretYn }" />' data-notice-yn='<c:out value="${ board.noticeYn }" />' >
													비밀글 
												</a>
											</c:when>
											<c:otherwise>
												<a href="#" class="boardTitle" data-idx='<c:out value="${ board.idx }" />' data-secret-yn='<c:out value="${ board.secretYn }" />' data-notice-yn='<c:out value="${ board.noticeYn }" />' >
												 	<c:out value="${ board.title }" />
												 </a>
											</c:otherwise>
										</c:choose>
									</c:otherwise>
								</c:choose>
							</c:when>
							<c:otherwise>
								<!-- 답글 -->
								<c:choose>
									<c:when test="${ board.secretYn eq true }">
										<a href="#" class="boardTitle" data-idx='<c:out value="${ board.idx }" />' data-secret-yn='<c:out value="${ board.secretYn }" />' data-notice-yn='<c:out value="${ board.noticeYn }" />' >
											<c:forEach var="i" begin="1" end="${ board.depth }">
										 		&nbsp; 
										 	</c:forEach>
											 ㄴRE: 비밀글 
										</a>
									</c:when>
									<c:otherwise>
										<a href="#" class="boardTitle" data-idx='<c:out value="${ board.idx }" />' data-secret-yn='<c:out value="${ board.secretYn }" />' data-notice-yn='<c:out value="${ board.noticeYn }" />' >
										 	<c:forEach var="i" begin="1" end="${ board.depth }">
										 		&nbsp; 
										 	</c:forEach>
										 	ㄴRE: <c:out value="${ board.title }" />
										 </a>
									</c:otherwise>
								</c:choose>
							</c:otherwise>
						</c:choose>
					</td>
					<td>
						<c:out value="${ board.writer }" />
					</td>
					<td>
						<fmt:formatDate var="insertDate" value="${ parseDateTime }" type="Date" pattern="yyyy-MM-dd" />
						${ insertDate }
					</td>
					<td>
						<fmt:formatDate var="insertTime" value="${ parseDateTime }" type="Date" pattern="HH:mm" /> 
						${ insertTime }
					</td>
					<td>
						<c:out value="${ board.viewCnt }" />
					</td>
				</tr>
			</c:forEach>
		</tbody>
	</table>
	<div id = "paging"></div>
</body>
<script src="https://code.jquery.com/jquery-1.12.4.min.js"></script>
<script type="text/javascript">
	const $rowCheck = $('input[name=rowCheck]')
	const $allCheck = $('#allCheck')

	$(document).ready(() => {
		
		/* 페이지 갯수 계산해서 a태그 생성 */
		for(let i=0; i<${ boardList.pageLength }; i++){
			const pagingNum = i+1
			const pagingA = $('<a>',{
				'text': pagingNum,
				'id': 'page'+pagingNum,
				'href': '#',
				'data-num': pagingNum,
				'class': 'pagingTag'
			})
			$('#paging').append(pagingA)
			
		}
	})
	
	/* 체크박스 여기서 */
	$allCheck.on('click', (e) => {
		let valCheck = false
		
		for( const val of $rowCheck ){
			if(!val.checked) {
				
				valCheck = true
				break
			} 
		}
		$rowCheck.prop('checked', valCheck)
		$(e.currentTarget).prop('checked', valCheck)
		
	})
	
	$rowCheck.on('click', (e) => {
		let valCheck = true
		for(const val of $rowCheck) {
			if(!val.checked) {
				valCheck = false
				break
			}
		}
		$allCheck.prop('checked', valCheck)
	})
	
</script>
</html>
