package com.board.service;

import java.util.ArrayList;
//import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.board.domain.BoardDTO;
import com.board.domain.Paging;
import com.board.mapper.BoardMapper;

@Service
public class BoardServiceImpl implements BoardService {

	@Autowired
	private BoardMapper boardMapper;
	
	/** 행당 갯수 */
	private static final Integer rowNum = 10;
	
	@Override
	public Map<String,Object> getBoardList(BoardDTO boardDTO) {
		
		Map<String,Object> rtnVal = new HashMap<>(); 
		Paging paging = new Paging();
		
		int pageNum = boardDTO.getPageNum() != null && boardDTO.getPageNum() != 0 ? boardDTO.getPageNum() : 1;
		
		paging.setPageNum(pageNum);
		this.setPaging(paging);
		
		List<BoardDTO> lists = boardMapper.selectBoardList(paging);
		
//		List<BoardDTO> list = new ArrayList<>();
		
//		for (BoardDTO listItem : lists) {
//			if(listItem.isNoticeYn()) {
//				listItem.setTitle("#공지# "+listItem.getTitle());
//			}
//			list.add(listItem);
//		};
		
		List<BoardDTO> realList = new ArrayList<>();
		
		
		for(int i=0; i<lists.size(); i++) { // 전체순회
			// depth1 
			long idx=0;
			if(lists.get(i).getDepth()==1 && lists.get(i).getParentIdx() == 0) {
				idx = lists.get(i).getIdx();
				realList.add(lists.get(i));
			}
			for(int j=0; j<lists.size(); j++) {
				// depth2 
				long idx1=0;
				if(lists.get(j).getDepth()==2 && idx == lists.get(j).getParentIdx()) {
					idx1 = lists.get(j).getIdx();
					realList.add(lists.get(j));
				}
				for(int x=0; x<lists.size(); x++) {
					// depth3
					if(lists.get(x).getDepth() == 3 && idx1 == lists.get(x).getParentIdx() ) {
						realList.add(lists.get(x));
					}
				}
			}
		}
		
		rtnVal.put("Total", paging.getTotal());
		rtnVal.put("Data", realList);
		rtnVal.put("pageLength", paging.getPageLength());
		
		
		return rtnVal;
	}
	
	private Paging setPaging(Paging paging) {
		
		int pageNum = paging.getPageNum();
		int total = boardMapper.selectBoardTotalCount();
		
		paging.setTotal(total);
		paging.setPageLength((total-1)/rowNum + 1);
		paging.setStart((pageNum-1) * rowNum);
		paging.setRowNum(rowNum);
//		paging.setNum((pageNum-1) * 5 + 1); 
//		paging.setNum(total - ((pageNum-1)*rowNum));
		
		return paging;
	}
	
	@Override
	public boolean registerBoard(BoardDTO boardDTO) {
		int resultCnt = 0;
		this.setGroupNo(boardDTO);
		this.setDepth(boardDTO);
		
		if(boardDTO.getIdx() == null) {
			boardDTO.setIdx(boardMapper.getLastIdx()+1);
			resultCnt = boardMapper.insertBoard(boardDTO);
		}
		else {
			
			resultCnt = boardMapper.updateBoard(boardDTO);
		}
		
		return resultCnt == 0 ? false : true;
	}
	
	/** 계층형으로 인한 추가 */
	/** 댓글등록 임시 */
	
	
	/** 그룹번호(group_no) 세팅 */
	@Override
	public BoardDTO setGroupNo(BoardDTO boardDTO) {
	
		Integer getGroupNo = boardDTO.getGroupNo();
		Integer groupNo = getGroupNo == null ? boardMapper.getLastGroupNo()+1 : getGroupNo;
		boardDTO.setGroupNo(groupNo);
		
		return boardDTO;
	}
	
	/** 그룹내 정렬번호(depth) 세팅 */
	@Override
	public BoardDTO setDepth(BoardDTO boardDTO) {
		
		boardDTO.setDepth(boardMapper.getLastDepth(boardDTO)+1);
		
		return boardDTO;
	}
	
	
	/** =========================================================== */

	@Override
	@Transactional
	public Map<String, Object> deleteBoard(BoardDTO boardDTO) {
		Map<String, Object> rtnVal = new HashMap<String, Object>();
		int resultCnt = 0;
		
		for(Long selIdx : boardDTO.getIdxList() ) {
			resultCnt += boardMapper.deleteBoard(selIdx);
		}
		
		String data = resultCnt >=1 ? "삭제되었습니다" : "삭제에 실패했습니다";
		rtnVal.put("Data", data);
		
		return rtnVal;
	}
	
	@Override
	public int getViewCnt(Long idx) {
		
		int resultCnt = boardMapper.setViewCnt(idx);
		
		return resultCnt;
	}
	
	/* ====================================================================== */
	
	/* getBoardDetailChk에 하나로 합침 */
	@Deprecated
	@Override
	public Map<String, Object> getBoardDetail(Long idx) {
		
		//TODO 한번더 비밀글인지 체크
		
		Map<String, Object> rtnVal = new HashMap<String, Object>();
		
		BoardDTO list = boardMapper.selectBoardDetail(idx);
		rtnVal.put("Data", list);
		
		return rtnVal;
	}
	
	@Deprecated
	@Override
	public Map<String, Object> pswdCheck(BoardDTO boardDTO) {
		
		Map<String, Object> rtnVal = new HashMap<>();
		String selPswd = boardMapper.getPswd(boardDTO);
		boolean pswdChk = selPswd.equals(boardDTO.getPswd()) ? true : false;
		rtnVal.put("Data", pswdChk);
		
		return rtnVal;
	}
	
	/* ====================================================================== */	
	
	@Override
	public Map<String, Object> getBoardDetailChk(BoardDTO boardDTO){
		Map<String, Object> rtnVal = new HashMap<String, Object>();
		BoardDTO list = boardMapper.selectBoardDetail(boardDTO.getIdx());
		boolean pswdChk = true;
		
		if(boardDTO.isSecretYn() && list.isSecretYn()) {
			String selPswd = boardMapper.getPswd(boardDTO);
			pswdChk = selPswd.equals(boardDTO.getPswd()) ? true : false;
		} 
		
		if(pswdChk) {
			this.getViewCnt(boardDTO.getIdx());
			rtnVal.put("Data", list);	
		} 
		return rtnVal;
	}
	
}
