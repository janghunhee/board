package com.board.service;

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
	
	// 전체 조회
	@Override
	public Map<String,Object> getBoardList(BoardDTO boardDTO) {
		
		Map<String,Object> rtnVal = new HashMap<>(); 
		
		Integer getPageNum = boardDTO.getPageNum();
		int pageNum = getPageNum != null && getPageNum != 0 ? getPageNum : 1;
		
		Paging paging = this.setPaging(pageNum);
		
		List<BoardDTO> lists = boardMapper.selectBoardList(paging);
		
		rtnVal.put("Total", paging.getTotal());
		rtnVal.put("Data", lists);
		rtnVal.put("pageLength", paging.getPageLength());
		
		return rtnVal;
	}
	
	// 상세조회
	@Override
	public Map<String, Object> getBoardDetailChk(BoardDTO boardDTO){
		Map<String, Object> rtnVal = new HashMap<String, Object>();
		BoardDTO list = boardMapper.selectBoardDetail(boardDTO.getIdx());
		boolean pswdChk = true;
			
		if(list.isSecretYn()) {
			String selPswd = boardMapper.getPswd(boardDTO);
			pswdChk = selPswd.equals(boardDTO.getPswd());
		} 
		
		if(pswdChk) {
			this.getViewCnt(boardDTO.getIdx());
			rtnVal.put("Data", list);	
		} 
		
		return rtnVal;
	}
	
	// 등록,수정,댓글등록
	@Override
	@Transactional
	public boolean registerBoard(BoardDTO boardDTO) {
		int resultCnt = 0;
		
		// 새글등록 - idx null, parentIdx null
		if(boardDTO.getIdx() == null && boardDTO.getParentIdx() == null) {
			boardDTO.setIdx(boardDTO.getIdx() == null ? boardMapper.getLastIdx() : boardDTO.getIdx());
			this.setReorder(boardDTO);
			resultCnt = boardMapper.insertBoard(boardDTO);
		}
		
		// 글 수정 - idx , parentIdx null
		if(boardDTO.getIdx() != null && boardDTO.getParentIdx() != null) {
			this.updateBoard(boardDTO);
			resultCnt = boardMapper.updateBoard(boardDTO);
		}
		
		// 답글 등록 - idx null, parentIdx
		if(boardDTO.getIdx() == null && boardDTO.getParentIdx() != null) {
			boardDTO.setIdx(boardDTO.getIdx() == null ? boardMapper.getLastIdx() : boardDTO.getIdx());
			this.setReorder(boardDTO);
			resultCnt = boardMapper.insertBoard(boardDTO);
		}
		
		return resultCnt == 0 ? false : true;
	}
	
	// 자식 글 공지 수정
	@Transactional
	private void updateBoard(BoardDTO boardDTO) {
		if(boardDTO.isNoticeYn() != boardMapper.selectBoardDetail(boardDTO.getIdx()).isNoticeYn()) {
			List<BoardDTO> list = boardMapper.selectChildIdx(boardDTO.getIdx());
			for(BoardDTO item : list) {
				item.setNoticeYn(boardDTO.isNoticeYn());
				boardMapper.updateBoard(item);
			}
		}
	}
	
	// 답글 페이지 이동시 기본값 세팅
	@Override
	public BoardDTO setReWrite(BoardDTO boardDTO) {
		//parent_idx를 가지고 부모글이 공지글인지 확인
		boardDTO.setNoticeYn(boardMapper.selectBoardDetail((long) boardDTO.getParentIdx()).isNoticeYn());
		
		return boardDTO;
	}
	
	// 삭제
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
	
	// 조회수 증가
	@Transactional
	private int getViewCnt(Long idx) {
		
		int resultCnt = boardMapper.setViewCnt(idx);
		
		return resultCnt;
	}
	
	// reorder 셋팅
	private BoardDTO setReorder(BoardDTO boardDTO) {
		//parent_idx가 없을땐 1, parent_idx가 있다면?
		Integer pIdx = boardDTO.getParentIdx();
		
		if(pIdx == null) {
			boardDTO.setParentIdx(0);
			boardDTO.setReorder(1);
		} else {
			boardDTO.setReorder(boardMapper.getReorder(pIdx));
		}
		
		return boardDTO;
	}
	
	// 페이징 셋팅
	private Paging setPaging(Integer pageNum) {
		int total = boardMapper.selectBoardTotalCount();
		
		// 빌더패턴 적용
		Paging paging = Paging.builder()
							  .total(total)
							  .pageNum(pageNum)
							  .pageLength((total-1)/rowNum + 1)
							  .start((pageNum-1) * rowNum)
							  .rowNum(rowNum)
							  .build();
		
		return paging;
	}
	
}
