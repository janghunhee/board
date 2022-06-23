package com.board.service;

import java.util.ArrayList;
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
	
	// 전체 조회
	@Override
	public Map<String,Object> getBoardList(BoardDTO boardDTO) {
		
		Map<String,Object> rtnVal = new HashMap<>();
		this.setPaging(boardDTO);
		List<BoardDTO> lists = boardMapper.selectBoardList(boardDTO);
		
		rtnVal.put("Total", boardDTO.getTotal());
		rtnVal.put("Data", lists);
		rtnVal.put("pageLength", boardDTO.getPageLength());
		
		return rtnVal;
	}
	
	// 상세조회
	@Override
	public Map<String, Object> getBoardDetailChk(BoardDTO boardDTO){
		Map<String, Object> rtnVal = new HashMap<String, Object>();
		BoardDTO list = boardMapper.selectBoardDetail(boardDTO.getIdx());
		boolean pswdChk = true;
			
		if(list.isSecretYn()) {
			String selPswd = boardMapper.getPswd(boardDTO.getIdx());
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
	public Map<String, Integer> registerBoard(List<BoardDTO> boardList) {
		Map<String, Integer> rtnVal = new HashMap<String, Integer>();
		int successCnt = 0;
		BoardDTO board = boardList.get(0);
		
		// 글 수정 - idx , parentIdx null
		if(board.getIdx() != null && board.getParentIdx() != null) {
			try {
				successCnt = boardMapper.updateBoard(board);
				this.updateChild(board);
			} catch(Exception e) {
				e.printStackTrace();
			}
		}

		// 답글 등록 - idx null, parentIdx
		if(board.getIdx() == null && board.getParentIdx() != null) {
			board.setIdx(board.getIdx() == null ? boardMapper.getLastIdx() : board.getIdx());
			this.setReorder(board);
			try {
				successCnt = boardMapper.insertBoard(board);
			} catch(Exception e) {
				e.printStackTrace();
			}
		}
		
		// 새글등록 - idx null, parentIdx null
		if(board.getIdx() == null && board.getParentIdx() == null) {
			int getIdx = boardMapper.getLastIdx();
			for(BoardDTO item : boardList) {
				this.setReorder(item);
				item.setIdx(getIdx++);
				try {
					successCnt += boardMapper.insertBoard(item);
				} catch(Exception e) {
					e.printStackTrace();
				}
			}
		}
		
		int total = boardList.size();
		
		rtnVal.put("total", total);
		rtnVal.put("success", successCnt);
		rtnVal.put("fail", total - successCnt);
		
		return rtnVal;
	}
	
	// 자식 글 공지 수정
	@Transactional
	private void updateChild(BoardDTO boardDTO) {
		if(boardDTO.isNoticeYn() != boardMapper.selectBoardDetail(boardDTO.getIdx()).isNoticeYn()) {
			List<BoardDTO> list = boardMapper.selectChildIdx(boardDTO.getIdx());
			for(BoardDTO item : list) {
				item.setNoticeYn(boardDTO.isNoticeYn());
				boardMapper.updateChild(item);
			}
		}
	}
	
	// 답글 페이지 이동시 기본값 세팅
	@Override
	public BoardDTO setReWrite(BoardDTO boardDTO) {
		//parent_idx를 가지고 부모글이 공지글인지 확인
		boardDTO.setNoticeYn(boardMapper.selectBoardDetail(boardDTO.getParentIdx()).isNoticeYn());
		
		return boardDTO;
	}
	
	// 삭제
	@Override
	@Transactional
	public Map<String, Object> deleteBoard(BoardDTO boardDTO) {
		Map<String, Object> rtnVal = new HashMap<String, Object>();
		int resultCnt = 0;
		int childCnt = 0;
		
		for(Integer selIdx : boardDTO.getIdxList() ) {
			List<BoardDTO> childIdx = boardMapper.selectChildIdx(selIdx);
			for(BoardDTO deleteIdx : childIdx) {
				resultCnt += boardMapper.deleteBoard(deleteIdx.getIdx());
				childCnt += 1;
			}
		}
		String data = resultCnt == childCnt ? "삭제되었습니다" : "삭제에 실패했습니다";
		rtnVal.put("Data", data);
		
		return rtnVal;
	}
	
	// 조회수 증가
	@Transactional
	private int getViewCnt(Integer idx) {
		
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
	private Paging setPaging(BoardDTO boardDTO) {
		int total = boardMapper.selectBoardTotalCount(boardDTO);
		if(boardDTO.getPageNum() == null) {
			boardDTO.setPageNum(1);
		}
		if(boardDTO.getRowNum() == null) {
			boardDTO.setRowNum(10);
		}
		Integer rowNum = boardDTO.getRowNum();
		
		// 빌더패턴 적용 -> 상속때문에 적용x
//		Paging paging = Paging.builder()
//							  .total(total)
//							  .pageNum(pageNum)
//							  .pageLength((total-1)/ROWNUM + 1)
//							  .start((pageNum-1) * ROWNUM)
//							  .rowNum(ROWNUM)
//							  .build();
		
		boardDTO.setTotal(total);
		boardDTO.setPageLength((total/rowNum) + 1);
		boardDTO.setStart((boardDTO.getPageNum()-1) * rowNum);
		
		
		return boardDTO;
	}
	
}
