package com.plogging.backend.waste.dto;

import org.apache.commons.csv.CSVRecord;

public record WasteDisposalItemResponse(
	String localGovernmentCode,
	String managementNumber,
	String sidoName,
	String sigunguName,
	String managementAreaName,
	String targetAreaName,
	String dischargePlaceType,
	String dischargePlace,
	String generalWasteMethod,
	String foodWasteMethod,
	String recyclableWasteMethod,
	String bulkWasteMethod,
	String generalWasteDays,
	String foodWasteDays,
	String recyclableWasteDays,
	String generalWasteTime,
	String foodWasteTime,
	String recyclableWasteTime,
	String bulkWasteTime,
	String nonCollectionDays,
	String departmentName,
	String departmentPhone,
	String dataCriteriaDate,
	String dataUpdatedAt,
	String lastModifiedAt
) {

	public static WasteDisposalItemResponse from(CSVRecord record) {
		return new WasteDisposalItemResponse(
			value(record, "개방자치단체코드"), value(record, "관리번호"),
			value(record, "시도명"), value(record, "시군구명"),
			value(record, "관리구역명"), value(record, "관리구역대상지역명"),
			value(record, "배출장소유형"), value(record, "배출장소"),
			value(record, "생활쓰레기배출방법"), value(record, "음식물쓰레기배출방법"),
			value(record, "재활용품배출방법"), value(record, "일시적다량폐기물배출방법"),
			value(record, "생활쓰레기배출요일"), value(record, "음식물쓰레기배출요일"),
			value(record, "재활용품배출요일"),
			timeRange(record, "생활쓰레기배출시작시각", "생활쓰레기배출종료시각"),
			timeRange(record, "음식물쓰레기배출시작시각", "음식물쓰레기배출종료시각"),
			timeRange(record, "재활용품배출시작시각", "재활용품배출종료시각"),
			timeRange(record, "일시적다량폐기물배출시작시각", "일시적다량폐기물배출종료시각"),
			value(record, "미수거일"), value(record, "관리부서명"),
			value(record, "관리부서전화번호"), value(record, "데이터기준일자"),
			value(record, "데이터갱신시점"), value(record, "최종수정시점")
		);
	}

	private static String value(CSVRecord record, String column) {
		if (!record.isMapped(column) || !record.isSet(column)) return null;
		String value = record.get(column).trim();
		return value.isEmpty() ? null : value;
	}

	private static String timeRange(CSVRecord record, String startColumn, String endColumn) {
		String start = value(record, startColumn);
		String end = value(record, endColumn);
		if (start == null) return end;
		if (end == null) return start;
		return start + "~" + end;
	}
}
