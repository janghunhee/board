package com.board.service;

import java.util.List;
//import java.util.List;
import java.util.Map;

import com.board.domain.BoardDTO;

public interface BoardService {
	
	public Map<String, Object> getBoardList(BoardDTO boardDTO);
	
	public Map<String, Object> getBoardDetailChk(BoardDTO boardDTO);
	
	public Map<String, Integer> registerBoard(List<BoardDTO> boardList);
	
	public Map<String, Object> deleteBoard(BoardDTO boardDTO);
	
	public BoardDTO setReWrite(BoardDTO boardDTO);

}
