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
		<span>
		 	�� <c:out value="${ boardList.Total }" />��
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
					<th>��ȣ</th>
					<th>����</th>
					<th>�ۼ���</th>
					<th>�����</th>
					<th>��� �ð�</th>
					<th>��ȸ��</th>
				</tr>
			</thead>
		</table>
		
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
			
	/* �ߺ����� ���̴� selector */
	const $boardDetail = $('#boardDetail')
	const $detailBtn = $('#detailBtn')
	const $detailHeader = $('#detailHeader')
	
	/* ����¡ �ӽ� */
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
		
		/* üũ�ڽ� */
		
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
	
	/* �ΰ����ĺ� ajax �Լ� */
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
	
	/* ������ ���� */
	const setBoardDetail = function(param) {
		const noticeYn = param.noticeYn ? '#����#' : ''
		
		$detailHeader.text('�Խñ� ��')
		$('#noticeDetail').text(noticeYn)
		$('#titleDetail').text(param.Data.title)
		$('#writerDetail').text(param.Data.writer)
		$('#contentDetail').text(param.Data.content)
		$('#viewCntDetail').text(param.Data.viewCnt)
	}
	
	/* ���� Ŭ���� event */
	$(document).on('click','a.boardTitle', (e) => {
		e.preventDefault()
		const $this = $(e.currentTarget)
		const idx = $this.data('idx')
		const groupNo = $this.data('group-no')
		const secretYn = $this.data('secret-yn')
		
		const upBtn = $('<button>',{
			'text': '����',
			'id': 'goUpdate',
			'data-idx': idx
		})
		
		const reBtn = $('<button>',{
			'text': '���',
			'id': 'replyWrite',
			'data-group-no': groupNo,
			'data-notice-yn': $this.data('notice-yn'),
			'data-pidx' : $this.data('idx') 
		})
		
		if(secretYn) {
			const pswdChk = prompt('��й�ȣ�� �Է��ϼ���')
			getDetailPswdChk(idx, pswdChk, secretYn)
			.then((board) => {
				if(!board.Data){
					$detailHeader.text('��б� �Դϴ�')
					$boardDetail.hide()
					alert('��й�ȣ�� Ȯ�����ּ���')
					
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
	
	/* �۾��� ��ư Ŭ���� event */
	$('#doWrite').on('click', () => {
		location.assign('/board/write.do')
	})
	
	/* ���� ��ư Ŭ���� event */
	$(document).on('click', '#goUpdate',(e) => {
		/* location.assign('/board/write.do?idx='+$(e.currentTarget).data('idx')) */
		/* get��� idx(key��) ���������� post������� ���� */
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
	
	/* ������ư Ŭ���� */
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
		if(window.confirm('�����Ͻðڽ��ϱ�?')){
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
			alert('������ ��ҵǾ����ϴ�.')
		}
		
	})
	
	/* ��۹�ư Ŭ���� */
	$(document).on('click', '#replyWrite', (e) => {
		/* location.assign('/board/write.do?groupNo='+$(e.currentTarget).data('group-no')+'&noticeYn='+$(e.currentTarget).data('notice-yn')) */
		const $this = $(e.currentTarget)
		
		const form = $('<form>',{
			'method': 'POST',
			'action': '/board/reWrite'
		})
		/* ��������� parameter = idx(p_idx�� ���). groupNo, noticeYn */
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