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
	<div id = tableBody>
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
		</table>
		
	</div>

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
			
	/* 중복으로 쓰이는 selector */
	const $boardDetail = $('#boardDetail')
	const $detailBtn = $('#detailBtn')
	const $detailHeader = $('#detailHeader')
	
	/* 페이징 임시 */
	$(document).ready(() => {
		
		$.ajax({
			url: '/board/list.do',
			type: 'POST',
			data: {
				pageNum : '1'
			},
			dataType: 'html',
		})
		.done(function(result) {
			$('#tableBody').html(result);
		})
		
		/* 체크박스 */
		
	})
	
	$(document).on('click','a.pagingTag', (e) => {
		e.preventDefault()
		const num = $(e.currentTarget).data('num')
		console.log(num)
		$.ajax({
			url: '/board/list.do',
			type: 'POST',
			data: {
				pageNum : num
			},
			dataType: 'html'
		})
		.done(function(result) {
			$('#tableBody').html(result);
		})
	})
	
	/* 두개합쳐본 ajax 함수 */
	const getDetailPswdChk = (idxP, pswdP, secretYnP) => {
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
	
	/* 데이터 셋팅 */
	const setBoardDetail = function(param) {
		const noticeYn = param.noticeYn ? '#공지#' : ''
		
		$detailHeader.text('게시글 상세')
		$('#noticeDetail').text(noticeYn)
		$('#titleDetail').text(param.Data.title)
		$('#writerDetail').text(param.Data.writer)
		$('#contentDetail').text(param.Data.content)
		$('#viewCntDetail').text(param.Data.viewCnt)
	}
	
	/* 제목 클릭시 event */
	$(document).on('click','a.boardTitle', (e) => {
		e.preventDefault()
		const $this = $(e.currentTarget)
		const idx = $this.data('idx')
		const groupNo = $this.data('group-no')
		const secretYn = $this.data('secret-yn')
		
		const upBtn = $('<button>',{
			'text': '수정',
			'id': 'goUpdate',
			'data-idx': idx
		})
		
		const reBtn = $('<button>',{
			'text': '답글',
			'id': 'replyWrite',
			'data-group-no': groupNo,
			'data-notice-yn': $this.data('notice-yn'),
			'data-pidx' : $this.data('idx') 
		})
		
		if(secretYn) {
			const pswdChk = prompt('비밀번호를 입력하세요')
			getDetailPswdChk(idx, pswdChk, secretYn)
			.then((board) => {
				if(!board.Data){
					$detailHeader.text('비밀글 입니다')
					$boardDetail.hide()
					alert('비밀번호를 확인해주세요')
					
				} else {
					setBoardDetail(board)
					$boardDetail.show()
					$detailBtn.empty()
					$detailBtn.append(upBtn)
					$detailBtn.append(reBtn)
				}
			})
		} else {
			getDetailPswdChk(idx)
			.then((board) => {
				setBoardDetail(board)
				$boardDetail.show()
			})
			$detailBtn.empty()
			$detailBtn.append(upBtn)
			$detailBtn.append(reBtn)
		}
	})
	
	/* 글쓰기 버튼 클릭시 event */
	$('#doWrite').on('click', () => {
		location.assign('/board/write.do')
	})
	
	/* 수정 버튼 클릭시 event */
	$(document).on('click', '#goUpdate',(e) => {
		/* location.assign('/board/write.do?idx='+$(e.currentTarget).data('idx')) */
		/* get방식 idx(key값) 노출이유로 post방식으로 변경 */
		const form = $('<form>',{
			'method': 'POST',
			'action': '/board/reWrite'
		})
		
		const idx = $('<input>',{
			'type': 'hidden',
			'name': 'idx',
			'value': $(e.currentTarget).data('idx'),
		})
		
		form.append(idx)
		form.appendTo('body')
		form.submit()
	}) 
	
	/* 삭제버튼 클릭시 */
	$('#doDelete').on('click', () => {
		const rowCheck = $('input[name=rowCheck]')
		const checkedIdx = []
		
		for ( const val of rowCheck ) {
			/* console.log(val.dataset.idx) */
			if(val.checked) {
				checkedIdx.push(val.dataset.idx)
			}
		}
		console.log(checkedIdx)
		if(window.confirm('삭제하시겠습니까?')){
			$.ajax({
				url: '/board/delete.do',
				type: 'PUT',
				data: {
					idxList: checkedIdx
				},
				dataType: 'json'
			})
			.success((msg) => {
				alert(msg.Data)
				location.reload()
			})
		} else {
			alert('삭제가 취소되었습니다.')
		}
		
	})
	
	/* 답글버튼 클릭시 */
	$(document).on('click', '#replyWrite', (e) => {
		/* location.assign('/board/write.do?groupNo='+$(e.currentTarget).data('group-no')+'&noticeYn='+$(e.currentTarget).data('notice-yn')) */
		const $this = $(e.currentTarget)
		
		const form = $('<form>',{
			'method': 'POST',
			'action': '/board/reWrite'
		})
		/* 보내줘야할 parameter = idx(p_idx로 사용). groupNo, noticeYn */
		const pIdx = $('<input>',{
			'type': 'hidden',
			'name': 'parentIdx',
			'value': $this.data('pidx'),
		})
		const groupNo = $('<input>',{
			'type': 'hidden',
			'name': 'groupNo',
			'value': $this.data('groupNo')
		})
		const noticeYn = $('<input>',{
			'type': 'hidden',
			'name': 'noticeYn',
			'value': $this.data('notice-yn')
		})
		
		form.append(pIdx)
		form.append(groupNo)
		form.append(noticeYn)
		form.appendTo('body')
		form.submit()
	})
	
</script>
</html>