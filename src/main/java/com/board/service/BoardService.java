package com.board.service;

//import java.util.List;
import java.util.Map;

import com.board.domain.BoardDTO;

public interface BoardService {
	
//	public List<BoardDTO> getBoardList();
	
	public Map<String, Object> getBoardList(BoardDTO boardDTO);
	
	public boolean registerBoard(BoardDTO boardDTO);
	
	public Map<String, Object> getBoardDetail(Long idx);
	
	public Map<String, Object> deleteBoard(BoardDTO boardDTO);
	
	public int getViewCnt(Long idx);
	
	public Map<String, Object> pswdCheck(BoardDTO boardDTO);
	
	public Map<String, Object> getBoardDetailChk(BoardDTO boardDTO);
	
	public BoardDTO setGroupNo(BoardDTO boardDTO);
	
	public BoardDTO setDepth(BoardDTO boardDTO);
}
