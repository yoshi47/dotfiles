#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const readline = require('readline');

// Constants
const PLANS_DIR = path.join(process.env.HOME, '.claude', 'plans');

// Read JSON from stdin
let input = '';
process.stdin.on('data', chunk => input += chunk);
process.stdin.on('end', async () => {
  try {
    const data = JSON.parse(input);

    // Extract values
    const model = data.model?.display_name || 'Unknown';
    const sessionId = data.session_id;

    // Use pre-calculated context window data from Claude Code
    const ctx = data.context_window || {};
    const percentage = ctx.used_percentage != null
      ? Math.round(ctx.used_percentage)
      : 0;
    const totalTokens = (ctx.current_usage?.input_tokens || 0)
      + (ctx.current_usage?.cache_creation_input_tokens || 0)
      + (ctx.current_usage?.cache_read_input_tokens || 0);

    // Format token display
    const tokenDisplay = formatTokenCount(totalTokens);

    // Find session slug for plan display
    let sessionSlug = null;
    if (sessionId) {
      sessionSlug = await findSessionSlug(sessionId);
    }

    // Color coding for percentage
    let percentageColor = '\x1b[32m'; // Green
    if (percentage >= 70) percentageColor = '\x1b[33m'; // Yellow
    if (percentage >= 90) percentageColor = '\x1b[31m'; // Red

    // Get session plan name
    const sessionPlan = getSessionPlanName(sessionSlug);
    const planDisplay = sessionPlan ? ` | 📋 ${sessionPlan}` : '';

    // Build status line
    const sessionIdDisplay = sessionId ? ` | 🔑 ${sessionId}` : '';
    const statusLine = `[${model}] 🪙 ${tokenDisplay} | ${percentageColor}${percentage}%\x1b[0m${sessionIdDisplay}${planDisplay}`;

    console.log(statusLine);

  } catch (error) {
    console.error('Error processing status:', error.message);
  }
});

async function findSessionSlug(sessionId) {
  const projectsDir = path.join(process.env.HOME, '.claude', 'projects');
  if (!fs.existsSync(projectsDir)) return null;

  const projectDirs = fs.readdirSync(projectsDir)
    .map(dir => path.join(projectsDir, dir))
    .filter(dir => fs.statSync(dir).isDirectory());

  for (const projectDir of projectDirs) {
    const transcriptFile = path.join(projectDir, `${sessionId}.jsonl`);
    if (fs.existsSync(transcriptFile)) {
      return await extractSlug(transcriptFile);
    }
  }
  return null;
}

function extractSlug(filePath) {
  return new Promise((resolve) => {
    let slug = null;
    const rl = readline.createInterface({
      input: fs.createReadStream(filePath),
      crlfDelay: Infinity
    });

    rl.on('line', (line) => {
      if (slug) return;
      try {
        const entry = JSON.parse(line);
        if (entry.slug) {
          slug = entry.slug;
          rl.close();
        }
      } catch (e) {}
    });

    rl.on('close', () => resolve(slug));
    rl.on('error', () => resolve(null));
  });
}

function formatTokenCount(tokens) {
  if (tokens >= 1000000) {
    return `${(tokens / 1000000).toFixed(1)}M`;
  } else if (tokens >= 1000) {
    return `${(tokens / 1000).toFixed(1)}K`;
  }
  return tokens.toString();
}

function getSessionPlanName(slug) {
  if (!slug) return null;
  try {
    const planFile = path.join(PLANS_DIR, `${slug}.md`);
    if (fs.existsSync(planFile)) return slug;
    return null;
  } catch (e) {
    return null;
  }
}
