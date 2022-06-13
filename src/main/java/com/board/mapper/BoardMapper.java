package com.board.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;

import com.board.domain.BoardDTO;

@Mapper
public interface BoardMapper {

	public List<BoardDTO> selectBoardList(BoardDTO boardDTO);
	
	public int insertBoard(BoardDTO params);
	
	public BoardDTO selectBoardDetail(Long idx);
	
	public int updateBoard(BoardDTO params);
	
	public int deleteBoard(Long idx);
	
	public int selectBoardTotalCount(BoardDTO boardDTO);
	
	public Long getLastIdx();
	
	public int setViewCnt(Long idx);
	
	public String getPswd(BoardDTO boardDTO);
	
	public Integer getReorder(Integer parentidx);
	
	public List<BoardDTO> selectChildIdx(Long idx);
	
	public void updateChild(BoardDTO boardDTO);

}
