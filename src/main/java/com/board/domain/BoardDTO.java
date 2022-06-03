package com.board.domain;

import java.time.LocalDateTime;
import java.util.List;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class BoardDTO {
	
	/** 번호 */
	private Long idx;
	
	/** 페이지 번호 */
	private Integer pageNum;
	
	/** 번호 */
	private Integer num;
	
	/** 제목 */
	private String title;
	
	/** 내용 */
	private String content;
	
	/** 작성자 */
	private String writer;
	
	/** 비밀번호 */
	private String pswd;
	
	/** 조회수 */
	private int viewCnt;
	
	/** 공지 여부 */
	private boolean noticeYn;
	
	/** 비밀 여부 */
	private boolean secretYn;
	
	/** 삭제 여부 */
	private String deleteYn;
	
	/** 등록일 */
	private LocalDateTime insertTime;
	
	/** 수정일 */
	private LocalDateTime updateTime;

	/** 삭제일 */
	private LocalDateTime deleteTime;
	
	/** 번호 리스트 */
	private List<Long> idxList;
	
	/** 그룹번호 */
	private Integer groupNo;
	
	/** 그룹정렬번호 */
	private Integer depth;
	
	/** 페이지당 행 수 */
	private Integer rowNum;
	
	private Integer parentIdx;
	
	private Integer reorder;
}
