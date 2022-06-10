<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="EUC-KR">
<title>Insert title here</title>
</head>
<style>
table, td, th {
	border: 1px solid black;
	border-collapse: collapse;
}

th, td {
	text-align: center;
}

.title{
	text-align: left;
}

a {
	text-decoration:none;
}
</style>
<body>
	<div>
		<h2>게시판</h2>
	</div>
	<div id = "tableBody" ></div>
	<form id="searchForm">
		<div id = "search">
			<select id="searchKey" name="searchKey">
				<option value="title">제목</option>
				<option value="writer">작성자</option>
			</select>
			<input type = "text" id="searchVal" name="searchVal">
			<button type = "button" id="searchBtn">검색</button>
		</div>
	</form>
	<div class="btn-area" style="margin-top: 30px">
		<button id="doWrite">글쓰기</button>
		<button id="doDelete">삭제</button>
	</div>

	<div>
		<h2 id="detailHeader"></h2>
	</div>

	<div id="boardDetail">
		<div>
			<label id="noticeDetail"></label>
		</div>
		<div>
			<label>제목 : </label> <label id="titleDetail"></label>
		</div>
		<div>
			<label>이름 : </label> <label id="writerDetail"></label>
		</div>
		<div>
			<label>내용 : </label> <label id="contentDetail"></label>
		</div>
		<div>
			<label>조회수 : </label> <label id="viewCntDetail"></label>
		</div>
		<div id="detailBtn"></div>
	</div>
</body>
<script src="https://code.jquery.com/jquery-1.12.4.min.js"></script>
<script type="text/javascript">
			
	// 중복으로 쓰이는 selector 
	const $boardDetail = $('#boardDetail')
	const $detailBtn = $('#detailBtn')
	const $detailHeader = $('#detailHeader')
	const $tableBody = $('#tableBody')
	
	// 모듈화 ? 
	const boardFunc = (function() {
		
		const getDetailPswdChk = function(idxP, pswdP, secretYnP) {
			
			return new Promise((resolve, reject) => {
				$.ajax({
					url: '/board/listChk',
					type: 'GET',
					data: {
						idx: idxP,
						pswd: pswdP,
						secretYn: secretYnP
					},
					dataType: 'json',
					success: function(data, textStatus, jqXHR) {
						resolve(data)
					},
					error: function(jqXHR, textStatus, errorThrown){
						reject(errorThrown)
					}
				})
			})
		}
		
		const setBoardDetail = function(param) {
			const noticeChk = param.Data.noticeYn ? '#공지#' : ''
			
			$detailHeader.text('게시글 상세')
			$('#noticeDetail').text(noticeChk)
			$('#titleDetail').text(param.Data.title)
			$('#writerDetail').text(param.Data.writer)
			$('#contentDetail').text(param.Data.content)
			$('#viewCntDetail').text(param.Data.viewCnt)
			
			$boardDetail.show()
		}
		
		const appendBtn = function(upBtn, reBtn) {
			$detailBtn.empty()
			$detailBtn.append(upBtn)
			$detailBtn.append(reBtn)
		}
		
		const makeHidden = function(name, value) {
			const hidden =  $('<input>', {
								'type': 'hidden',
								'name': name,
								'value': value
							})
			return hidden
		}
		
		const makeBtn = function(text, id) {
			const btn = $('<button>' ,{
							'text': text,
							'id': id,
						})
						
			return btn
		}
		
		const makeForm = function(url) {
			const form = $('<form>', {
				'method': 'POST',
				'action': '/board/'+url
			}) 
			
			return form
		}
		
		const makeAjax = function(urlP, typeP, dataP, dataTypeP) {
			const ajax = $.ajax({
							url: '/board/'+urlP,
							type: typeP,
							data: dataP,
							dataType: dataTypeP,
						})
			return ajax
		}
		
		return {
			getDetailPswdChk,
			setBoardDetail,
			appendBtn,
			makeHidden,
			makeBtn,
			makeForm,
			makeAjax
		}
	})()
	
	// 처음 들어왔을때 pageNum=1 
	$(document).ready(() => {
		const $ajax = boardFunc.makeAjax('list.do', 'POST', { pageNum : '1' }, 'html')
		$ajax.done(function(result) {
			$tableBody.html(result)
		})
	})
	
	// paging 숫자 클릭시 Event
	$(document).on('click','a.pagingTag', (e) => {
		e.preventDefault()

		const $ajax = boardFunc.makeAjax('list.do','POST',{ pageNum: $(e.currentTarget).data('num') },'html')
		$ajax.done(function(result){
			$tableBody.html(result)
		})
	})
	
	// 검색기능 TODO
	$('#searchBtn').on('click', (e) => {
		/* console.log($('#searchForm').serialize()) */
		const $ajax = boardFunc.makeAjax('list.do', 'POST', $('#searchForm').serialize(), 'html')
		
		$ajax.done(function(result) {
			$tableBody.html(result)
		})
		/* $('#searchVal').val('') */
	})
	
	// 제목 클릭시 event 
	$(document).on('click','a.boardTitle', (e) => {
		e.preventDefault()
		const $this = $(e.currentTarget)
		const idx = $this.data('idx')
		const secretYn = $this.data('secret-yn')
		
		const upBtn = boardFunc.makeBtn('수정', 'goUpdate')
		upBtn.attr('data-idx', idx)

		const reBtn = boardFunc.makeBtn('답글', 'replyWrite')
		reBtn.attr('data-parent-idx', idx)

		if(secretYn) {
			const pswdChk = prompt('비밀번호를 입력하세요')
			boardFunc.getDetailPswdChk(idx, pswdChk, secretYn)
			.then((board) => {
				if(!board.Data){
					$detailHeader.text('비밀글 입니다')
					$boardDetail.hide()
					alert('비밀번호를 확인해주세요')
					
				} else {
					boardFunc.setBoardDetail(board)
					boardFunc.appendBtn(upBtn, reBtn)
				}
			})
		} else {
			boardFunc.getDetailPswdChk(idx)
			.then((board) => {
				boardFunc.setBoardDetail(board)
				boardFunc.appendBtn(upBtn, reBtn)
			})
		}
	})
	
	// 글쓰기 버튼 클릭시 event 
	$('#doWrite').on('click', () => {
		location.assign('/board/goWrite')
	})
	
	// 수정 버튼 클릭시 event 
	$(document).on('click', '#goUpdate',(e) => {

		const form = boardFunc.makeForm('goUpdate')
		const idx = boardFunc.makeHidden('idx', $(e.currentTarget).data('idx'))
		
		form.append(idx)
		form.appendTo('body')
		form.submit()
	}) 
	
	// 삭제버튼 클릭시 
	$('#doDelete').on('click', () => {
		const rowCheck = $('input[name=rowCheck]')
		const checkedIdx = []
		
		for ( const val of rowCheck ) {
			if(val.checked) {
				checkedIdx.push(val.dataset.idx)
			}
		}
		
		if(window.confirm('삭제하시겠습니까?')){
			const $ajax = boardFunc.makeAjax('delete.do', 'PUT', { idxList: checkedIdx }, 'json')
			$ajax.success(function(msg) {
				alert(msg.Data)
				location.reload()
			})
		} else {
			alert('삭제가 취소되었습니다.')
		}
	})
	
	// 답글버튼 클릭시 
	$(document).on('click', '#replyWrite', (e) => {

		const form = boardFunc.makeForm('goReWrite')
		// 보내줘야할 parameter = idx(parentIdx로 사용), noticeYn 
		const pIdx = boardFunc.makeHidden('parentIdx', $(e.currentTarget).data('parent-idx'))
		
		form.append(pIdx)
		form.appendTo('body')
		form.submit()
	})
	
	
	
</script>
</html>