package com.board.controller;

import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.board.domain.BoardDTO;
import com.board.service.BoardService;

@Controller
public class BoardController {

	@Autowired
	private BoardService boardService;

	@GetMapping("/")
	public String home(Model model) {
		model.addAttribute("name", "HomeController");
		return "index";
	}

	/* 등록/수정 페이지 이동 */
	@GetMapping("/board/write.do")
	public String openBoardWrite(BoardDTO boardDTO, Model model) {

		if (boardDTO.getIdx() == null) {
			model.addAttribute("board", new BoardDTO());
		} else {
//			Map<String, Object> board = boardService.getBoardDetail(idx);
			Map<String, Object> boardMap = boardService.getBoardDetailChk(boardDTO);
			BoardDTO board = (BoardDTO) boardMap.get("Data");
			model.addAttribute("board", board);
		}

		return "board/write";
	}
	
	/* 댓글 클릭시 페이지 이동*/
	@PostMapping("/board/reWrite")
	public String openBoardReWrite(BoardDTO boardDTO, Model model) {
		if(boardDTO.getIdx() == null) {
			model.addAttribute("board", boardDTO);
		} else {
			Map<String, Object> boardMap = boardService.getBoardDetailChk(boardDTO);
			BoardDTO board = (BoardDTO) boardMap.get("Data");
			model.addAttribute("board", board);
		}
		return "board/write";
	}
	
	
	/* 전체조회 */
	@PostMapping("/board/list.do")
	public String openBoardList( BoardDTO boardDTO, Model model) {
		Map<String, Object> list = boardService.getBoardList(boardDTO);

		model.addAttribute("boardList", list);

		return "board/boardList";
	}
	
	/* 리스트로 */
	@GetMapping("/board/goList")
	public String goList() {
		return "/board/list";
	}
	
	/* 상세조회 */
	@Deprecated
	@GetMapping("/board/detail.do")
	public String getBoardDetail(@RequestParam(value = "idx", required = false) Long idx, Model model) {

		boardService.getViewCnt(idx);
		Map<String, Object> board = boardService.getBoardDetail(idx);
		model.addAttribute("board", board);

		return "board/detail";
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
	
	/* 비밀번호 확인 */
	@Deprecated
	@ResponseBody
	@GetMapping(value = "/board/pswdCheck.do")
	public Map<String, Object> pswdCheck(BoardDTO boardDTO) {

		return boardService.pswdCheck(boardDTO);

	}

	@ResponseBody
	@GetMapping("/board/listChk")
	public Map<String, Object> getDetailPswdChk(BoardDTO boardDTO) {
		return boardService.getBoardDetailChk(boardDTO);
	}

}
