public with sharing class EcreditWebToCaseCompController {
	@InvocableMethod(label='Create Attachment')
	public static void createAttachment(List<AttachmentInput> inputs) {
		List<Attachment> attachments = new List<Attachment>();
		List<ContentDocumentLink> documentLinks = new List<ContentDocumentLink>();

		Set<Id> versionIds = new Set<Id>();

		for (AttachmentInput input : inputs) {
			versionIds.addAll(input.versionIds);
		}

		Map<Id, String> fileNameMap = getFileNameByVersionIds(versionIds);
		Map<Id, String> base64DataMap = getBase64DataByVersionIds(versionIds);
		Map<Id, String> fileExtMap = getFileTypeByVersionIds(versionIds);
		String attName = '';

		try {
			for (AttachmentInput input : inputs) {
				for (Id versionId : input.versionIds) {
					if (fileNameMap.containsKey(versionId) && base64DataMap.containsKey(versionId)) {
						if (!fileNameMap.get(versionId).contains(fileExtMap.get(versionId))) {
							attName = fileNameMap.get(versionId) + '.' + fileExtMap.get(versionId);
						} else {
							attName = fileNameMap.get(versionId);
						}

						Attachment attachment = new Attachment(
							ParentId = input.caseId,
							Name = fileNameMap.get(versionId) + '.' + fileExtMap.get(versionId),
							Body = EncodingUtil.base64Decode(base64DataMap.get(versionId))
						);
						attachments.add(attachment);
					}
				}
			}
			insert attachments;

			for (Attachment attachment : attachments) {
				ContentDocumentLink documentLink = new ContentDocumentLink(
					ContentDocumentId = attachment.Id,
					LinkedEntityId = attachment.ParentId,
					ShareType = 'V',
					Visibility = 'AllUsers'
				);
				documentLinks.add(documentLink);
			}
			upsert documentLinks;
		} catch (Exception e) {
			System.debug('An error occurred while creating attachment: ' + e.getMessage());
		}
	}

	private static Map<Id, String> getFileNameByVersionIds(Set<Id> versionIds) {
		Map<Id, String> fileNameMap = new Map<Id, String>();

		List<ContentVersion> contentVersions = [SELECT Id, Title, FileType FROM ContentVersion WHERE Id IN :versionIds];
		for (ContentVersion cv : contentVersions) {
			fileNameMap.put(cv.Id, cv.Title);
		}

		return fileNameMap;
	}

	private static Map<Id, String> getFileTypeByVersionIds(Set<Id> versionIds) {
		Map<Id, String> fileExtMap = new Map<Id, String>();

		List<ContentVersion> contentVersions = [SELECT Id, FileExtension FROM ContentVersion WHERE Id IN :versionIds];
		for (ContentVersion cv : contentVersions) {
			fileExtMap.put(cv.Id, cv.FileExtension);
		}

		return fileExtMap;
	}

	private static Map<Id, String> getBase64DataByVersionIds(Set<Id> versionIds) {
		Map<Id, String> base64DataMap = new Map<Id, String>();

		List<ContentVersion> contentVersions = [SELECT Id, VersionData FROM ContentVersion WHERE Id IN :versionIds];
		for (ContentVersion cv : contentVersions) {
			if (cv.VersionData != null) {
				Blob fileData = cv.VersionData;
				base64DataMap.put(cv.Id, EncodingUtil.base64Encode(fileData));
			}
		}

		return base64DataMap;
	}

	public class AttachmentInput {
		@InvocableVariable(label='Case ID' required=true)
		public Id caseId;

		@InvocableVariable(label='Version IDs' required=true)
		public List<Id> versionIds;
	}
}
