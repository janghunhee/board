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
	padding: 5px;
}
</style>
<body>
	<div>
		<h2>게시판</h2>
	</div>
	<div id = "rowNumDiv">
		<select id="selectRowNum" name="rowNum">
			<option value="5">5</option>
			<option value="10" selected>10</option>
			<option value="20">20</option>
		</select>
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
	const $selectRowNum = $('#selectRowNum')
	const $searchBtn = $('#searchBtn')
	
	// 모듈화 ?
	const boardFunc = (function() {
		const $searchForm = $('#searchForm')
		
		const getDetailPswdChk = function(idxP, pswdP, secretYnP) {
			
			/* return new Promise((resolve, reject) => {
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
			}) */
			param = {
				idx: idxP,
				pswd: pswdP,
				secretYn: secretYnP
			}
			
			return this.makeAjax('listChk', 'GET', param, 'json')
		}
		
		const setBoardDetail = function(param) {
			const paramData = param.Data
			const noticeChk = paramData.noticeYn ? '#공지#' : ''
			
			$detailHeader.text('게시글 상세')
			$('#noticeDetail').text(noticeChk)
			$('#titleDetail').text(paramData.title)
			$('#writerDetail').text(paramData.writer)
			$('#contentDetail').text(paramData.content)
			$('#viewCntDetail').text(paramData.viewCnt)
			
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
		
		const getBoardList = function(pageNumP, rowNumP) {
			const param = {
					pageNum: pageNumP,
					rowNum: rowNumP
			}
			this.makeAjax('list.do', 'POST', param, 'html').done(function(result) {
				$tableBody.html(result)
			})
		}
		
		const getSearchList = function() {
			$searchForm.append($selectRowNum)
			this.makeAjax('list.do', 'POST', $searchForm.serialize(), 'html').done(function(result) {
				$tableBody.html(result)
				$('#rowNumDiv').append($selectRowNum)
			})
		}
		
		return {
			getDetailPswdChk,
			setBoardDetail,
			appendBtn,
			makeHidden,
			makeBtn,
			makeForm,
			makeAjax,
			getBoardList,
			getSearchList
		}
	})()
	
	// 처음 들어왔을때 pageNum=1 
	$(document).ready(() => {
		boardFunc.getBoardList()
	})
	
	// paging 숫자 클릭시 Event
	$(document).on('click','a.pagingTag', (e) => {
		e.preventDefault()
		boardFunc.getBoardList($(e.currentTarget).data('num'), $selectRowNum.val())
	})
	
	// rownum 클릭시
	$selectRowNum.on('change', (e) => {
		boardFunc.getSearchList()
	})
	
	// 검색기능
	$searchBtn.on('click', (e) => {
		boardFunc.getSearchList()
	})
	
	/* 엔터키 설정 */
	$('#searchVal').on('keydown', (e) => {
		if(e.keyCode == 13) {
			e.preventDefault()
			$searchBtn.trigger('click')
		}
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
			.done((board) => {
				if(!board.Data){
					$detailHeader.text('비밀글 입니다')
					$boardDetail.hide()
					alert('비밀번호를 확인해주세요')
					
				} else {
					boardFunc.setBoardDetail(board)
					upBtn.attr('data-pswd', pswdChk)
					boardFunc.appendBtn(upBtn, reBtn)
				}
			})
		} else {
			boardFunc.getDetailPswdChk(idx)
			.done((board) => {
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
		const $this = $(e.currentTarget)
		
		const form = boardFunc.makeForm('goUpdate')
		const idx = boardFunc.makeHidden('idx', $this.data('idx'))
		if($this.data('pswd')) {
			form.append(boardFunc.makeHidden('pswd', $this.data('pswd')))
		}
		
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
	
	// 체크박스 
	$(document).on('click', '#allCheck', (e) => {
		let valCheck = false
		
		for( const val of $('input[name=rowCheck]') ){
			if(!val.checked) {
				
				valCheck = true
				break
			}
		}
		$('input[name=rowCheck]').prop('checked', valCheck)
		$(e.currentTarget).prop('checked', valCheck)
	})
	
	$(document).on('click', 'input[name=rowCheck]', (e) => {
		let valCheck = true
		for(const val of $('input[name=rowCheck]')) {
			if(!val.checked) {
				valCheck = false
				break
			}
		}
		$('#allCheck').prop('checked', valCheck)
	})
</script>
</html>