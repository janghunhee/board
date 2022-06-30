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
			<div id="form0" class="formInput" data-cnt="1">
				<div><h3 id="formNum">1.</h3></div>
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
					<input type="text" class="title" name="title" data-validate-name="제목" value='<c:out value="${ board.title }" />' placeholder="제목을 입력해 주세요." required />
				</div>
				<div>
					<label for="writer">이름</label> 
					<input type="text" class="writer" name="writer" data-validate-name="이름" value='<c:out value="${ board.writer }" />' placeholder="이름을 입력해 주세요." required />
				</div>
				<div>
					<label for="pswd">비밀번호</label> 
					<input type="password" class="pswd" name="pswd" data-validate-name="비밀번호" placeholder="비밀번호를 입력해 주세요" disabled />
				</div>
				<div>
					<label for="content">내용</label>
					<div>
						<textarea class="content" name="content" data-validate-name="내용" placeholder="내용을 입력해 주세요." required><c:out value="${ board.content }" /></textarea>
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
		
		const makeAjax = function(urlP, typeP, dataP, dataTypeP, contentTypeP) {
			return $.ajax({
				url: '/board/'+urlP,
				type: typeP,
				data: dataP,
				dataType: dataTypeP,
				contentType : contentTypeP,
				traditional: 'true'
			})
		}
		
		const writeForm = function() {
			++formCnt
			const $clone = $('#form0').clone()
			const $checkbox = $clone.find('input[type=checkbox]')
			const formNum = formCnt + 1
			
			$clone.find('#formNum').text(formNum+'.')
			$clone.find('input, textarea').val('')
			$clone.prop('id', 'form'+formCnt)
			$clone.attr('data-cnt', formNum)
			$checkbox.prop({
					'checked' : false,
					'disabled' : false
			})
			$checkbox.val('false')
			$clone.find('.pswd').prop('disabled', true)
			$clone.appendTo('#form')
		}
		
		const removeForm = function() {
			if(formCnt > 0) {
				$('.formInput').remove('#form'+formCnt)
				formCnt--
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
		
		const secretChange = function() {
			$('input[name="secretYn"]').trigger('change')
		}
		
		const valCheckfunc = function(itemVal, itemSel) {
			return !itemVal ? itemSel.data('validateName') : ''
		}
		
		return {
			makeAjax,
			writeForm,
			registForm,
			removeForm,
			secretChange,
			valCheckfunc
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
		const $parentVal = $('.parentIdx').val()
		// 수정으로 들어왔을때 체크박스 기본값
		$noticeYn.prop('checked', $noticeYn.val() === 'true' ? true : false)
		$secretYn.prop('checked', $secretYn.val() === 'true' ? $pswd.prop('disabled', false) : false)
		
		if($noticeYn.is(':checked')){
			$secretYn.val(false)
			$secretYn.prop('disabled', true)
		}
		
		// 체크박스 값이없으면 value=false로 셋팅
		if(!$(':checkbox').val()) {
			$noticeYn.val(false)
			$secretYn.val(false)
		}
		
		// 답글일때
		if($parentVal != '' && $parentVal != 0){
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
				$secret.prop({
					'checked': false,
					'disabled' : true
				})
				boardWrite.secretChange()
			} else {
				$notice.val(false)
				$secret.prop('disabled', false)
				boardWrite.secretChange()
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

		/* $('.formInput').each(function(){
			let valName = ''
			if(!$(this).find('.title').val()) {
				valName = $(this).find('.title').data('validate-name')
				valChk = false
			} else if(!$(this).find('.writer').val()) {
				valName = $(this).find('.writer').data('validate-name')
				valChk = false
			} else if($(this).find('.secretYn').val() === 'true' && !$(this).find('.pswd').val()) {
				valName = $(this).find('.pswd').data('validate-name')
				valChk = false
			} else if(!$(this).find('.content').val()) {
				valName = $(this).find('.content').data('validate-name')
				valChk = false
			}
			
			if(!valChk) {
				alert(valName+'을 입력해주세요.')
				return false
			}
		}) */
			
		// 비용절감을 위해 each문을 formInput 전체가 아닌 필요한 태그들만 돌며 validation
		$('div.formInput :text, :password, textarea').each(function(index, item) {
			let valName = ''
			const itemName = item.name
			const itemVal = $(item).val()
			const formInput = $(item).closest('div.formInput')
			/* if( (itemName == 'title' && !itemVal) ||
				   (itemName =='writer' && !itemVal) ||
				   (itemName =='pswd' && !itemVal && $(item).closest(formInput).find('input[name="secretYn"]').val() == 'true') ||
				   (itemName =='content' && !itemVal)) {
						valName = $(item).data('validateName')
			}
			
			if(valName) {
				alert($(item).closest(formInput).data('cnt') + '번 글의 ' + valName+'을 입력해주세요.')
				valChk = false
				return false
			} */
			
			/* const valCheckfunc = function() {
				return valName = !itemVal ? $(item).data('validateName') : ''
			} */
			
			switch(itemName) {
				case 'title' :
					valName = boardWrite.valCheckfunc(itemVal, $(item))
					break
				case 'writer' :
					valName = boardWrite.valCheckfunc(itemVal, $(item))
					break
				case 'pswd' :
					if(formInput.find('input[name="secretYn"]').val() == 'true') {
						valName = boardWrite.valCheckfunc(itemVal, $(item))
					}
					break
				case 'content' :
					valName = boardWrite.valCheckfunc(itemVal, $(item))
					break
			}
			
			if(valName) {
				alert(formInput.data('cnt') + '번 글의 ' + valName +'을 입력해주세요.')
				valChk = false
				return false
			}
		})
		
		if(valChk){
			boardWrite.makeAjax('register.do', 'POST', JSON.stringify(boardWrite.registForm()), 'json', 'application/json')
			.done(function(result) {
				alert('총 : '+ result.total +' 성공 : ' + result.success + ' 실패 : ' + result.fail)
				location.replace('/board/goList')
			})
		}
	})
</script>
</html>