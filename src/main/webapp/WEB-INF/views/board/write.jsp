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
	<c:choose>
		<c:when test="${ empty board.idx and empty board.parentIdx  }">
			<div>
				<button type="button" id="addFormBtn"><span>+</span></button>
				<button type="button" id="removeBtn"><span>-</span></button>
			</div>
		</c:when>
	</c:choose>
	<div id="formDiv">
		<form id="form">
			<div id="form0" class="formInput">
				<div>
					<input type="hidden" class="idx" name="idx" value='<c:out value="${ board.idx }" />' />
					<input type="hidden" class="parentIdx" name="parentIdx" value='<c:out value="${ board.parentIdx }" />' />
				</div>
				<div>
					<label for="noticeYn">공지글 설정</label> 
					<input type="checkbox" class="noticeYn" name="noticeYn" value='<c:out value="${ board.noticeYn }" />' />
				</div>
				<div>
					<label for="secretYn">비밀글 설정</label> 
					<input type="checkbox" class="secretYn" name="secretYn" value='<c:out value="${ board.secretYn }" />' />
				</div>
				<div>
					<label for="title">제목</label> 
					<input type="text" class="title" name="title" value='<c:out value="${ board.title }" />' placeholder="제목을 입력해 주세요." required />
				</div>
				<div>
					<label for="writer">이름</label> 
					<input type="text" class="writer" name="writer" value='<c:out value="${ board.writer }" />' placeholder="이름을 입력해 주세요." required />
				</div>
				<div>
					<label for="pswd">비밀번호</label> 
					<input type="password" class="pswd" name="pswd" placeholder="비밀번호를 입력해 주세요" disabled />
				</div>
				<div>
					<label for="content">내용</label>
					<div>
						<textarea class="content" name="content" placeholder="내용을 입력해 주세요." required><c:out value="${ board.content }" /></textarea>
					</div>
				</div>
				<div>
					<span>==========================</span>
				</div>
			</div>
		</form>
	</div>
	<div>
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
	
	const $noticeYn = $('.noticeYn')
	const $secretYn = $('.secretYn')
	const $pswd = $('.pswd')
	const $formInput = $('.formInput')
	
	/* 모듈 */
	const boardWrite = (function() {
		
		let formCnt = 0
		
		const makeAjax = function(urlP, typeP, dataP, dataTypeP) {
			return $.ajax({
				url: '/board/'+urlP,
				type: typeP,
				data: dataP ,
				dataType: dataTypeP,
				traditional: 'true'
			})
		}
		
		const makeInput = function(typeP, nameP) {
			return $('<input>', {
				'type' : typeP,
				'name' : nameP
			})
		}
		
		const makeLabel = function(forP, valP) {
			const $label = $('<label>', { 'for' : forP })
			$label.text(valP)
			return $label
		}
		
		const writeForm = function() {
			++formCnt
			const $clone = $('#form0').clone()
			const $checkbox = $clone.find('input[type=checkbox]')
			$clone.prop('id', 'form'+formCnt)
			$clone.find('input[type=text]').val('')
			$checkbox.prop('checked', false)
			$checkbox.prop('disabled', false)
			$checkbox.val('false')
			$clone.find('.pswd').prop('disabled', true)
			$clone.find('textarea').val('')
			$clone.appendTo('#form')
			console.log(formCnt)
		}
		
		const removeForm = function() {
			if(formCnt > 0) {
				$('.formInput').remove('#form'+formCnt)
				formCnt--
				console.log(formCnt)
			} else {
				alert('삭제할 수 없습니다')
			}
		}
		
		const registForm = function() {
			const boardList = []
			for(let i=0; i<=formCnt; i++){
				const boardObj = {}
				boardObj.idx = $('.idx:eq('+ i +')').val(),
				boardObj.parentIdx = $('.parentIdx:eq('+ i +')').val(),
				boardObj.noticeYn = $('.noticeYn:eq('+ i +')').val(),
				boardObj.secretYn = $('.secretYn:eq('+ i +')').val(),
				boardObj.title = $('.title:eq('+ i +')').val(),
				boardObj.writer = $('.writer:eq('+ i +')').val(),
				boardObj.pswd = $('.pswd:eq('+ i +')').val(),
				boardObj.content = $('.content:eq('+ i +')').val()
				
				boardList.push(boardObj)
			}
			
			return boardList
			
		}

		return {
			makeInput : makeInput,
			makeAjax : makeAjax,
			writeForm : writeForm,
			registForm : registForm,
			makeLabel : makeLabel,
			removeForm : removeForm
		}
	})()
	
	$('#addFormBtn').on('click', () => {
		boardWrite.writeForm()
	})
	
	$('#removeBtn').on('click', () => {
		boardWrite.removeForm()
	})
	
	/* 수정으로 들어왔을 때 기본값 세팅 */
	$(document).ready(function() {
		// 수정으로 들어왔을때 체크박스 기본값
		$noticeYn.prop('checked', $noticeYn.val() === 'true' ? true : false)
		$secretYn.prop('checked', $secretYn.val() === 'true' ? $pswd.prop('disabled', false) : false)
		
		if($noticeYn.is(':checked')){
			$secretYn.val(false) 
			$secretYn.prop('disabled', true)
		}
		
		// 답글일때
		if($('.parentIdx').val() != '' && $('.parentIdx').val() != 0){
			//공지 변경 x 부모의 공지를 따른다.
			$noticeYn.prop('disabled', true)
		}
	})
	
	/* 체크박스 test */
	$(document).on('change', '.noticeYn', function() {
		$('.formInput').each(function() {
			const $notice = $(this).find('.noticeYn')
			const $secret = $(this).find('.secretYn')
			
			if($notice.is(':checked')) {
				$notice.val(true)
				$secret.prop('checked', false)
				$secret.prop('disabled', true)
				$secretYn.trigger('change')
			} else {
				$notice.val(false)
				$secret.prop('disabled', false)
				$secretYn.trigger('change')
			}
		})
	})
	
	$(document).on('change', '.secretYn', function() {
		$('.formInput').each(function() {
			const $secret = $(this).find('.secretYn')
			const $pswdf = $(this).find('.pswd')
			
			if($secret.is(':checked')) {
				$secret.val(true)
				$pswdf.prop('disabled', false)
			} else {
				$secret.val(false)
				$pswdf.prop('disabled', true) 
				$pswdf.val('')
			}
		})
	})
	
	
	/* 등록/수정 버튼 클릭시 */
	$('#submit').on('click', (e) => {
		let valChk = true

		$('.formInput').each(function(){
			if($(this).find('.title').val() === '') {
				alert('제목을 입력해주세요.')
				valChk = false
				return false
			} else if($(this).find('.writer').val() === '') {
				alert('이름을 입력해주세요.') 
				valChk = false
				return false
			} else if($(this).find('.secretYn').val() === 'true' && $(this).find('.pswd').val() === '') {
				alert('비밀번호를 입력해주세요.') 
				valChk = false
				return false
			} else if($(this).find('.content').val() === '') {
				alert('내용을 입력해주세요') 
				valChk = false
				return false
			}
		})
		
		if(valChk){
			$.ajax({
				url : '/board/register.do',
				type : 'POST',
				contentType : 'application/json',
				dataType : 'json',
				data : JSON.stringify(boardWrite.registForm())
			})
			.success(function(result) {
				if($('.idx').val() == '' && $('.parentIdx').val() == '' ){
					const total = result.total
					const success = result.success
					alert('총 : '+total+' 성공 : '+success+' 실패 : '+(total-success))
				} else {
					alert('성공')
				}
				location.replace('/board/goList')
			})
		} 
	})
</script>
</html>