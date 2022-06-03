<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="EUC-KR">
<title>Insert title here</title>
</head>
<body>
	<div>
		<c:choose>
			<c:when test="${ empty board.idx }">
				<c:choose>
					<c:when test="${ not empty board.parentIdx }">
						<h2>답글 등록</h2>
					</c:when>
					<c:otherwise>
						<h2>게시글 등록</h2>
					</c:otherwise>
				</c:choose>
			</c:when>
			<c:otherwise>
				<h2>게시글 수정</h2>
			</c:otherwise>
		</c:choose>
	</div>

	<div>
		<form id="form" action="/board/register.do" method="POST">
			<div>
				<input type="hidden" name="idx" value='<c:out value="${ board.idx }" />' />
				<input type="hidden" name="parentIdx" value='<c:out value="${ board.parentIdx }" />' />
			</div>
			<div>
				<label for="noticeYn">공지글 설정</label> 
				<input type="checkbox" id="noticeYn" value='<c:out value="${ board.noticeYn }" />' name="noticeYn" />
			</div>
			<div>
				<label for="secretYn">비밀글 설정</label> 
				<input type="checkbox" id="secretYn" value='<c:out value="${ board.secretYn }" />' name="secretYn" />
			</div>
			<div>
				<label for="title">제목</label> 
				<input type="text" id="title" name="title" value='<c:out value="${ board.title }" />' placeholder="제목을 입력해 주세요." required />
			</div>
			<div>
				<label for="writer">이름</label> 
				<input type="text" id="writer" name="writer" value='<c:out value="${ board.writer }" />' placeholder="이름을 입력해 주세요." required />
			</div>
			<div>
				<label for="pswd">비밀번호</label> 
				<input type="password" id="pswd" name="pswd" placeholder="비밀번호를 입력해 주세요" disabled />
			</div>
			<div>
				<label for="content">내용</label>
				<div>
					<textarea id="content" name="content" placeholder="내용을 입력해 주세요." required><c:out value="${ board.content }" /></textarea>
				</div>
			</div>
		</form>
	</div>
	<div class="submit">
		<button id="submit">
			<c:choose>
				<c:when test="${ empty board.idx }">
					등록
				</c:when>
				<c:otherwise>
					수정
				</c:otherwise>
			</c:choose>
		</button>
	</div>
</body>
<script src="https://code.jquery.com/jquery-1.12.4.min.js"></script>
<script type="text/javascript">
	
	const $noticeYn = $('#noticeYn')
	const $secretYn = $('#secretYn')
	const $pswd = $('#pswd')

	/* 수정으로 들어왔을 때 기본값 세팅 */
	$(document).ready(function() {
		$noticeYn.prop('checked', $noticeYn.val() === 'true' ? true : false)
		$secretYn.prop('checked', $secretYn.val() === 'true' ? $pswd.prop('disabled', false) : false)
		let groupNo = new URLSearchParams(location.search).get("groupNo")
		console.log(groupNo)
	})

	const checkVal = (e) => {
		const $this = $(e.currentTarget)
		const val = $this.val() === 'false' ? 'true' : 'false' 
		$this.val(val)
	}
	
	/* 체크박스 value 설정 */
	$noticeYn.change((e) => {
		checkVal(e)
	})
	
	$secretYn.change((e) => {
		checkVal(e)
		$(e.currentTarget).val() === 'true' ? $pswd.prop('disabled', false) : $pswd.prop('disabled', true) && $pswd.val('')
				console.log($pswd.val())
	})
	
	/* 등록/수정 버튼 클릭시 */
	$('#submit').on('click', (e) => {
		let groupNo = new URLSearchParams(location.search).get("groupNo")
		
		const groupHidden = $('<input>',{
			'type': 'hidden',
			'name': 'groupNo',
			'value': groupNo
		})
		$('#form').append(groupHidden)
		
		  $('#title').val() === '' ? alert('제목을 입력해주세요')
		: $('#writer').val() === '' ? alert('이름을 입력해주세요')
		: $('#content').val() === '' ? alert ('내용을 입력해주세요')
		: $secretYn.val() === 'true' && $pswd.val() === '' ? alert('비밀번호를 설정해주세요') 
		: $('#form').submit()
		
	})

</script>
</html>