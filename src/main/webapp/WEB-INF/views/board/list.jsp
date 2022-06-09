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
		<h2>�Խ���</h2>
	</div>
	<div id = tableBody>
	</div>

	<div class="btn-area" style="margin-top: 30px">
		<button id="doWrite">�۾���</button>
		<button id="doDelete">����</button>
	</div>

	<div>
		<h2 id="detailHeader"></h2>
	</div>

	<div id="boardDetail">
		<div>
			<label id="noticeDetail"></label>
		</div>
		<div>
			<label>���� : </label> <label id="titleDetail"></label>
		</div>
		<div>
			<label>�̸� : </label> <label id="writerDetail"></label>
		</div>
		<div>
			<label>���� : </label> <label id="contentDetail"></label>
		</div>
		<div>
			<label>��ȸ�� : </label> <label id="viewCntDetail"></label>
		</div>
		<div id="detailBtn"></div>
	</div>
</body>
<script src="https://code.jquery.com/jquery-1.12.4.min.js"></script>
<script type="text/javascript">
			
	// �ߺ����� ���̴� selector 
	const $boardDetail = $('#boardDetail')
	const $detailBtn = $('#detailBtn')
	const $detailHeader = $('#detailHeader')
	const $tableBody = $('#tableBody')
	
	// ���ȭ ? 
	const boardFunc = (function() {
		
		const makeAjax = function(urlP, typeP, dataP, dataTypeP) {
			const ajax = $.ajax({
							url: '/board/'+urlP,
							type: typeP,
							data: dataP,
							dataType: dataTypeP,
						})
			return ajax
		}
		
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
			const noticeChk = param.Data.noticeYn ? '#����#' : ''
			
			$detailHeader.text('�Խñ� ��')
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
			const hidden =  $('<input>',{
								'type': 'hidden',
								'name': name,
								'value': value
							})
			return hidden
		}
		
		const makeBtn = function(text, id) {
			const btn = $('<button>',{
							'text': text,
							'id': id,
						})
						
			return btn
		}
		
		const makeForm = function(url) {
			const form = $('<form>',{
				'method': 'POST',
				'action': '/board/'+url
			}) 
			
			return form
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
	
	// ó�� �������� pageNum=1 
	$(document).ready(() => {
		const $ajax = boardFunc.makeAjax('list.do', 'POST', { pageNum : '1' }, 'html')
		$ajax.done(function(result) {
			$tableBody.html(result)
		})
	})
	
	// paging ���� Ŭ���� Event
	$(document).on('click','a.pagingTag', (e) => {
		e.preventDefault()

		const $ajax = boardFunc.makeAjax('list.do','POST',{ pageNum: $(e.currentTarget).data('num') },'html')
		$ajax.done(function(result){
			$tableBody.html(result)
		})
	})
	
	// ���� Ŭ���� event 
	$(document).on('click','a.boardTitle', (e) => {
		e.preventDefault()
		const $this = $(e.currentTarget)
		const idx = $this.data('idx')
		const secretYn = $this.data('secret-yn')
		
		const upBtn = boardFunc.makeBtn('����', 'goUpdate')
		upBtn.attr('data-idx', idx)

		const reBtn = boardFunc.makeBtn('���', 'replyWrite')
		reBtn.attr('data-parent-idx', idx)

		if(secretYn) {
			const pswdChk = prompt('��й�ȣ�� �Է��ϼ���')
			boardFunc.getDetailPswdChk(idx, pswdChk, secretYn)
			.then((board) => {
				if(!board.Data){
					$detailHeader.text('��б� �Դϴ�')
					$boardDetail.hide()
					alert('��й�ȣ�� Ȯ�����ּ���')
					
				} else {
					boardFunc.setBoardDetail(board)
					boardFunc.appendBtn(upBtn, reBtn)
				}
			})
		} else {
			boardFunc.getDetailPswdChk(idx)
			.then((board) => {
				boardFunc.setBoardDetail(board)
			})
			boardFunc.appendBtn(upBtn, reBtn)
		}
	})
	
	// �۾��� ��ư Ŭ���� event 
	$('#doWrite').on('click', () => {
		location.assign('/board/goWrite')
	})
	
	// ���� ��ư Ŭ���� event 
	$(document).on('click', '#goUpdate',(e) => {

		const form = boardFunc.makeForm('goUpdate')
		const idx = boardFunc.makeHidden('idx', $(e.currentTarget).data('idx'))
		
		form.append(idx)
		form.appendTo('body')
		form.submit()
	}) 
	
	// ������ư Ŭ���� 
	$('#doDelete').on('click', () => {
		const rowCheck = $('input[name=rowCheck]')
		const checkedIdx = []
		
		for ( const val of rowCheck ) {
			if(val.checked) {
				checkedIdx.push(val.dataset.idx)
			}
		}
		
		if(window.confirm('�����Ͻðڽ��ϱ�?')){
			const $ajax = boardFunc.makeAjax('delete.do', 'PUT', { idxList: checkedIdx }, 'json')
			$ajax.success(function(msg) {
				alert(msg.Data)
				location.reload()
			})
		} else {
			alert('������ ��ҵǾ����ϴ�.')
		}
	})
	
	// ��۹�ư Ŭ���� 
	$(document).on('click', '#replyWrite', (e) => {

		const form = boardFunc.makeForm('goReWrite')
		// ��������� parameter = idx(parentIdx�� ���), noticeYn 
		const pIdx = boardFunc.makeHidden('parentIdx', $(e.currentTarget).data('parent-idx'))
		
		form.append(pIdx)
		form.appendTo('body')
		form.submit()
	})
	
</script>
</html>