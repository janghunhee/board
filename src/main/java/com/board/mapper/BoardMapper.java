package com.board.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;

import com.board.domain.BoardDTO;

@Mapper
public interface BoardMapper {

	public List<BoardDTO> selectBoardList(BoardDTO boardDTO);
	
	public int insertBoard(BoardDTO boardDTO);
	
	public BoardDTO selectBoardDetail(Integer idx);
	
	public int updateBoard(BoardDTO boardDTO);
	
	public int deleteBoard(Integer idx);
	
	public int selectBoardTotalCount(BoardDTO boardDTO);
	
	public Integer getLastIdx();
	
	public int setViewCnt(Integer idx);
	
	public String getPswd(Integer idx);
	
	public Integer getReorder(Integer parentidx);
	
	public List<BoardDTO> selectChildIdx(Integer idx);
	
	public void updateChild(BoardDTO boardDTO);

}
