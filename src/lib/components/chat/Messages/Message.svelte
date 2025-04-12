<script lang="ts">
	import { toast } from 'svelte-sonner';

	import { tick, getContext, onMount, createEventDispatcher } from 'svelte';
	const dispatch = createEventDispatcher();
	const i18n = getContext('i18n');

	import { settings } from '$lib/stores';
	import { copyToClipboard } from '$lib/utils';

	import MultiResponseMessages from './MultiResponseMessages.svelte';
	import ResponseMessage from './ResponseMessage.svelte';
	import UserMessage from './UserMessage.svelte';

	export let chatId;
	export let idx = 0;

	export let history;
	export let messageId;

	export let user;

	export let gotoMessage;
	export let showPreviousMessage;
	export let showNextMessage;
	export let updateChat;

	export let editMessage;
	export let saveMessage;
	export let deleteMessage;
	export let rateMessage;
	export let actionMessage;
	export let submitMessage;

	export let regenerateResponse;
	export let continueResponse;
	export let mergeResponses;

	export let addMessages;
	export let triggerScroll;
	export let readOnly = false;
</script>

<div
	class="grid grid-cols-2 justify-between px-5 mb-3 w-full {($settings?.widescreenMode ?? null)
		? 'max-w-full'
		: 'max-w-6xl'} mx-auto rounded-lg group"
	
	
		
>
	{#if history.messages[messageId]}
		{#if history.messages[messageId].role === 'user'}
			<!-- Outer container for user + response -->

				<!-- Render User Message -->
				<UserMessage
					{user}
					{history}
					{messageId}
					isFirstMessage={idx === 0}
					siblings={history.messages[messageId].parentId !== null
						? (history.messages[history.messages[messageId].parentId]?.childrenIds ?? [])
						: (Object.values(history.messages)
								.filter((message) => message.parentId === null)
								.map((message) => message.id) ?? [])}
					{gotoMessage}
					{showPreviousMessage}
					{showNextMessage}
					{editMessage}
					{deleteMessage}
					{readOnly}
				/>

				<!-- Render corresponding response(s) -->
				{#if (history.messages[messageId].childrenIds?.length ?? 0) > 0}
					<!-- Pick the first child (response) for simple case -->
					{#each history.messages[messageId].childrenIds as responseId}
						{#if (history.messages[responseId]?.models?.length ?? 1) === 1}
							<ResponseMessage
								{chatId}
								{history}
								messageId={responseId}
								isLastMessage={responseId === history.currentId}
								siblings={history.messages[messageId].childrenIds}
								{gotoMessage}
								{showPreviousMessage}
								{showNextMessage}
								{updateChat}
								{editMessage}
								{saveMessage}
								{rateMessage}
								{actionMessage}
								{submitMessage}
								{deleteMessage}
								{continueResponse}
								{regenerateResponse}
								{addMessages}
								{readOnly}
							/>
						{:else}
							<MultiResponseMessages
								bind:history
								{chatId}
								messageId={responseId}
								isLastMessage={responseId === history?.currentId}
								{updateChat}
								{editMessage}
								{saveMessage}
								{rateMessage}
								{actionMessage}
								{submitMessage}
								{deleteMessage}
								{continueResponse}
								{regenerateResponse}
								{mergeResponses}
								{triggerScroll}
								{addMessages}
								{readOnly}
							/>
						{/if}
					{/each}
				{/if}
		{/if}
	{/if}
</div>