package com.plogging.backend.waste;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.nio.charset.Charset;
import java.util.List;
import java.util.Locale;
import java.util.Map;

import org.apache.commons.csv.CSVFormat;
import org.apache.commons.csv.CSVParser;
import org.springframework.core.io.ClassPathResource;
import org.springframework.stereotype.Service;

import com.plogging.backend.common.ApiException;
import com.plogging.backend.waste.dto.WasteDisposalItemResponse;
import com.plogging.backend.waste.dto.WasteDisposalPageResponse;

@Service
public class WasteDisposalService {

	private static final String CSV_PATH = "data/household_waste.csv";
	private static final Charset CSV_CHARSET = Charset.forName("MS949");
	private static final List<String> KEYWORD_COLUMNS = List.of(
		"관리구역명", "관리구역대상지역명", "배출장소유형", "배출장소",
		"생활쓰레기배출방법", "음식물쓰레기배출방법", "재활용품배출방법",
		"생활쓰레기배출요일", "음식물쓰레기배출요일", "재활용품배출요일", "미수거일"
	);

	public WasteDisposalPageResponse findAll(
		String sido,
		String sigungu,
		String keyword,
		int pageNo,
		int numOfRows
	) {
		ClassPathResource resource = new ClassPathResource(CSV_PATH);
		if (!resource.exists()) {
			throw ApiException.internalServerError("생활쓰레기 배출 정보 파일이 없습니다.");
		}

		try (
			InputStream inputStream = resource.getInputStream();
			BufferedReader reader = new BufferedReader(new InputStreamReader(inputStream, CSV_CHARSET));
			CSVParser parser = CSVFormat.DEFAULT.builder()
				.setHeader()
				.setSkipHeaderRecord(true)
				.setIgnoreEmptyLines(true)
				.get()
				.parse(reader)
		) {
			List<WasteDisposalItemResponse> filtered = parser.stream()
				.filter(record -> contains(record.toMap().get("시도명"), sido))
				.filter(record -> contains(record.toMap().get("시군구명"), sigungu))
				.filter(record -> matchesKeyword(record.toMap(), keyword))
				.map(WasteDisposalItemResponse::from)
				.toList();

			long offset = (long) (pageNo - 1) * numOfRows;
			int fromIndex = (int) Math.min(offset, filtered.size());
			int toIndex = Math.min(fromIndex + numOfRows, filtered.size());
			return new WasteDisposalPageResponse(
				"LOCAL_CSV", pageNo, numOfRows, filtered.size(), filtered.subList(fromIndex, toIndex)
			);
		} catch (IOException | RuntimeException exception) {
			throw ApiException.internalServerError("생활쓰레기 배출 정보를 불러오지 못했습니다.");
		}
	}

	private boolean matchesKeyword(Map<String, String> record, String keyword) {
		if (isBlank(keyword)) return true;
		return KEYWORD_COLUMNS.stream().anyMatch(column -> contains(record.get(column), keyword));
	}

	private boolean contains(String value, String query) {
		if (isBlank(query)) return true;
		return value != null && value.toLowerCase(Locale.ROOT).contains(query.trim().toLowerCase(Locale.ROOT));
	}

	private boolean isBlank(String value) {
		return value == null || value.isBlank();
	}
}
