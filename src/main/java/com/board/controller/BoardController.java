package com.board.controller;

import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import com.board.domain.BoardDTO;
import com.board.service.BoardService;

@Controller
public class BoardController {

	@Autowired
	private BoardService boardService;

	@GetMapping("/")
	public String home(Model model) {
		
		return "index";
	}
	
	/* 리스트로 */
	@GetMapping("/board/goList")
	public String goList() {
		
		return "/board/list";
	}
	
	/* 전체조회 */
	@PostMapping("/board/list.do")
	public String openBoardList( BoardDTO boardDTO, Model model) {
		
		model.addAttribute("boardList", boardService.getBoardList(boardDTO));
		return "board/boardList";
	}

	/* 새글 등록 페이지 이동 */
	@GetMapping("/board/goWrite")
	public String openBoardWrite(BoardDTO boardDTO) {
		return "board/write";
	}
	
	/* 답글 등록 페이지 이동*/
	@PostMapping("/board/goReWrite")
	public String openBoardReWrite(BoardDTO boardDTO, Model model) {
		
		model.addAttribute("board", boardService.setReWrite(boardDTO));
		return "board/write";
	}
	
	/* 게시글 수정 페이지 이동*/
	@PostMapping("/board/goUpdate")
	public String openBoardUpdate(BoardDTO boardDTO, Model model) {
		
		BoardDTO board = (BoardDTO) boardService.getBoardDetailChk(boardDTO).get("Data");
		model.addAttribute("board", board);
		return "board/write";
	}
	
	/* 등록/수정 */
	@PostMapping("/board/register.do")
	public String registBoard(BoardDTO boardDTO) {
		
		boardService.registerBoard(boardDTO);
		return "redirect:/board/goList";
	}

	/* 삭제 */
	@ResponseBody
	@PutMapping("/board/delete.do")
	public Map<String, Object> deleteBoard(BoardDTO boardDTO) {
		
		return boardService.deleteBoard(boardDTO);
	}
	
	/* 상세조회 */
	@ResponseBody
	@GetMapping("/board/listChk")
	public Map<String, Object> getDetailPswdChk(BoardDTO boardDTO) {
		
		return boardService.getBoardDetailChk(boardDTO);
	}
}
