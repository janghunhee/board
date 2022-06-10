package com.board.domain;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class Paging {

	private Integer total;
	
	private Integer pageNum;
	
	private Integer pageLength;
	
	private Integer start;
	
	private Integer rowNum;
	
}
