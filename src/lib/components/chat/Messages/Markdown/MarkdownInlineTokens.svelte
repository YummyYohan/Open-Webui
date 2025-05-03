<script lang="ts">
	import DOMPurify from 'dompurify';
	import { toast } from 'svelte-sonner';

	import type { Token } from 'marked';
	import { getContext } from 'svelte';

	const i18n = getContext('i18n');

	import { WEBUI_BASE_URL } from '$lib/constants';
	import { copyToClipboard, unescapeHtml } from '$lib/utils';

	import Image from '$lib/components/common/Image.svelte';
	import KatexRenderer from './KatexRenderer.svelte';
	import Source from './Source.svelte';
	import { onMount } from 'svelte';
	import { afterUpdate } from 'svelte';
	import html2canvas from 'html2canvas-pro';


	export let id: string;
	export let tokens: Token[];
	export let onSourceClick: Function = () => {};




	let showTooltip = false;
	let tooltipX = 0;
	let tooltipY = 0;
	let tooltipText = '';

	console.log("Tooltip script loaded!");

	function handleMouseEnter(event) {
		console.log("Showing tooltip:", tooltipText);

		const margin = 16;
		showTooltip = true;

		const { pageX, pageY } = event;
		const viewportWidth = window.innerWidth;
		const tooltipWidth = 256; // width in px matching Tailwind's w-64

		// Clamp X to prevent overflow
		let x = pageX + 10;
		if (x + tooltipWidth > viewportWidth - margin) {
			x = viewportWidth - tooltipWidth - margin;
		}

		tooltipX = x;
		tooltipY = pageY + 10;
		tooltipText = event.currentTarget.dataset.tooltip;

	}

	function handleMouseLeave() {
		console.log("Hiding tooltip");

		showTooltip = false;
	}

	function handleClick(event) {
		//console.log("handleClick", event.currentTarget.dataset.tooltip);
		const explanationType = event.currentTarget.dataset.tooltip;
		const buttonId = event.currentTarget.id; // <-- grab the id (4-digit random number)
		// Hide all explanations
		document.querySelectorAll(".explanation").forEach((el) => {
			el.style.display = "none"; // <-- instead of hidden = true
		});

		// Show the selected one
		const target = document.getElementById(`explanation-${buttonId}`);
		if (target) {
			target.style.display = "block"; // <-- instead of hidden = false
  		}
	}


	onMount(() => {
		const buttons = document.querySelectorAll('[data-tooltip]');
		buttons.forEach(button => {
			button.addEventListener('mouseenter', handleMouseEnter);
			button.addEventListener('mouseleave', handleMouseLeave);
			button.addEventListener('click', handleClick);
		});
	});


	// Create a merged HTML string for just text and html tokens
	//$ reactive statement
	$: mergedHtml = tokens
	.map((token) => {
		if (token.type === 'text' || token.type === 'html') {
			return token.text;
		}
		return '';
	})
	.join('');
	$: sanitizedMergedHtml = DOMPurify.sanitize(mergedHtml, {
		ADD_TAGS: ['mark', 'span', 'div', 'button', 'p'],
		ADD_ATTR: ['class', 'id', 'hidden', 'data-tooltip', 'data-explanation'],
	});

	afterUpdate(() => {
		const buttons = document.querySelectorAll('[data-tooltip]');
		buttons.forEach(button => {
		button.addEventListener('mouseenter', handleMouseEnter);
		button.addEventListener('mouseleave', handleMouseLeave);
		button.addEventListener('click', handleClick);
		});
  	});
</script>


	{#if showTooltip}
			<div
				class="fixed z-50 px-3 py-2 text-sm font-medium text-white bg-gray-900 rounded-lg shadow-lg max-w-xs break-words"
				style="top: {tooltipY}px; left: {tooltipX}px;">
				{tooltipText}
			</div>
		{/if}



{@html sanitizedMergedHtml}

{#each tokens as token}
	{#if token.type !== 'text' && token.type !== 'html'} <!-- already rendered above -->
		{#if token.type === 'escape'}
			{unescapeHtml(token.text)}
		{:else if token.type === 'link'}
			{#if token.tokens}
				<a href={token.href} target="_blank" rel="nofollow" title={token.title}>
					<svelte:self id={`${id}-a`} tokens={token.tokens} {onSourceClick} />
				</a>
			{:else}
				<a href={token.href} target="_blank" rel="nofollow" title={token.title}>{token.text}</a>
			{/if}
		{:else if token.type === 'image'}
			<Image src={token.href} alt={token.text} />
		{:else if token.type === 'strong'}	
			<strong><svelte:self id={`${id}-strong`} tokens={token.tokens} {onSourceClick} /></strong>
		{:else if token.type === 'em'}
				
			<em><svelte:self id={`${id}-em`} tokens={token.tokens} {onSourceClick} /></em>
		{:else if token.type === 'codespan'}
			<!-- svelte-ignore a11y-click-events-have-key-events -->
			<!-- svelte-ignore a11y-no-noninteractive-element-interactions -->
			<code
				class="codespan cursor-pointer"
				on:click={() => {
					copyToClipboard(unescapeHtml(token.text));
					toast.success($i18n.t('Copied to clipboard'));
				}}>{unescapeHtml(token.text)}</code
			>
		{:else if token.type === 'br'}
			<br />
		{:else if token.type === 'del'}
			<del><svelte:self id={`${id}-del`} tokens={token.tokens} {onSourceClick} /></del>
		{:else if token.type === 'inlineKatex'}
				inlineKate
			{#if token.text}
				<KatexRenderer content={token.text} displayMode={false} />
			{/if}
		{:else if token.type === 'iframe'}
			<iframe
				src="{WEBUI_BASE_URL}/api/v1/files/{token.fileId}/content"
				title={token.fileId}
				width="100%"
				frameborder="0"
				onload="this.style.height=(this.contentWindow.document.body.scrollHeight+20)+'px';"
			></iframe>
		{:else if token.type === 'html' && token.text.includes('<source_id')}
			<Source {id} {token} onClick={onSourceClick} />
		{/if}
	{/if}
{/each}

