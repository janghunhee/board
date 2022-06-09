package com.board.domain;

import lombok.Builder;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Builder
public class Paging {

	private Integer total;
	
	private Integer pageNum;
	
	private Integer pageLength;
	
	private Integer start;
	
	private Integer rowNum;
	
	
}
