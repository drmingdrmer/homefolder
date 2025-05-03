import { assertEquals, delay, Denops, path, test } from "./deps.ts";
import {
  actionCloseIssue,
  actionCreateIssueComment,
  actionEditIssue,
  actionEditIssueComment,
  actionEditIssueTitle,
  actionListAssignees,
  actionListIssue,
  actionListIssueComment,
  actionListLabels,
  actionOpenIssue,
  actionPreview,
  actionSearchIssues,
  actionUpdateAssignees,
  actionUpdateIssue,
  actionUpdateIssueComment,
  actionUpdateIssueTitle,
  actionUpdateLabels,
} from "./action_issue.ts";
import { buildSchema } from "./buffer.ts";
import {
  assertEqualFile,
  assertEqualTextFile,
  loadAutoload,
  newActionContext,
} from "./utils/test.ts";
import { vimRegister } from "./utils/helper.ts";
import { getIssue } from "./github/issue.ts";
import { main } from "./main.ts";
import { getActionCtx } from "./action.ts";

const ignore = Deno.env.get("TEST_LOCAL") !== "true";

test({
  mode: "all",
  name: "action open issue list buffer",
  fn: async (denops: Denops) => {
    const bufname = "gh://skanehira/test/issues";
    const schema = buildSchema(bufname);
    const ctx = {
      schema: schema,
      data: { filters: "state:open state:closed" },
    };
    await actionListIssue(denops, ctx);
    const actual = await denops.eval(`getline(1, "$")`) as string[];
    const file = path.join(
      "denops",
      "gh",
      "testdata",
      "want_issue_list.txt",
    );
    await assertEqualTextFile(file, actual.join("\n") + "\n");
  },
  timeout: 30000,
});

test({
  mode: "all",
  name: "action edit and update issue buffer",
  fn: async (denops: Denops) => {
    const bufname = "gh://skanehira/test/issues/26";
    const schema = buildSchema(bufname);
    const ctx = { schema: schema };
    await actionEditIssue(denops, ctx);
    const oldBody = await denops.call("getline", 1, "$") as string[];

    try {
      await denops.cmd("%d_");
      const newBody = ["hello", "world"];
      await denops.call("setline", 1, newBody);
      await actionUpdateIssue(denops, ctx);

      const newIssue = await getIssue({
        cond: {
          owner: schema.owner,
          repo: schema.repo,
          number: 26,
        },
      });

      assertEquals(newIssue.body.split("\n"), newBody);
    } finally {
      await denops.call("setline", 1, oldBody);
      await actionUpdateIssue(denops, ctx);
    }
  },
  timeout: 30000,
});

test({
  mode: "all",
  name: "action yank issue urls",
  fn: async (denops: Denops) => {
    await loadAutoload(denops);

    const ctx = newActionContext("gh://skanehira/test/issues");
    await actionListIssue(denops, ctx);
    await denops.call("gh#_action", "issues:yank");
    const got = await denops.call("getreg", vimRegister);
    const want = "https://github.com/skanehira/test/issues/27";
    assertEquals(got, want);
  },
  timeout: 30000,
});

test({
  mode: "all",
  name: "action search issue",
  fn: async (denops: Denops) => {
    const ctx = newActionContext("gh://skanehira/test/issues");
    ctx.data = { filters: "state:closed label:bug" };
    await actionSearchIssues(denops, ctx);
    const actual = await denops.call("getline", 1, "$");
    const file = path.join(
      "denops",
      "gh",
      "testdata",
      "want_issue_search.json",
    );
    await assertEqualFile(file, actual);
  },
  timeout: 30000,
});

test({
  mode: "all",
  name: "change issue state",
  fn: async (denops: Denops) => {
    const ctx = newActionContext("gh://skanehira/test/issues");
    ctx.data = { filters: "" };

    await loadAutoload(denops);
    await actionSearchIssues(denops, ctx);
    const current = await denops.call("getline", 1);
    assertEquals(
      current,
      "#27 test2  OPEN              ()                      ",
    );

    await actionCloseIssue(denops, ctx);
    const actual = await denops.call("getline", 1, "$");

    const dir = path.join(
      "denops",
      "gh",
      "testdata",
    );
    await assertEqualFile(
      path.join(
        dir,
        "want_issue_state_open.json",
      ),
      actual,
    );

    await actionOpenIssue(denops, ctx);

    await assertEqualFile(
      path.join(
        dir,
        "want_issue_state_close.json",
      ),
      await denops.call("getline", 1, "$"),
    );
  },
  timeout: 30000,
});

test({
  mode: "all",
  name: "update assignees",
  fn: async (denops: Denops) => {
    const ctx = newActionContext("gh://skanehira/test/issues/27");
    try {
      await actionListAssignees(denops, ctx);
      await denops.cmd("%d_");
      await denops.call("setline", 1, ["skanehira"]);
      await actionUpdateAssignees(denops, ctx);

      await denops.cmd("bw!");

      await actionListAssignees(denops, ctx);
      assertEquals(await denops.call("getline", 1, "$"), ["skanehira"]);
    } finally {
      await denops.cmd("%d_");
      await actionUpdateAssignees(denops, ctx);
    }
  },
  timeout: 30000,
});

test({
  mode: "all",
  name: "update label",
  fn: async (denops: Denops) => {
    const ctx = newActionContext("gh://skanehira/test/issues/27");
    try {
      await actionListLabels(denops, ctx);
      await denops.cmd("%d_");
      await denops.call("setline", 1, ["bug"]);
      await actionUpdateLabels(denops, ctx);

      await denops.cmd("bw!");
      await actionListLabels(denops, ctx);
      assertEquals(await denops.call("getline", 1, "$"), ["bug"]);
    } finally {
      await denops.cmd("%d_");
      await actionUpdateLabels(denops, ctx);
    }
  },
  timeout: 30000,
});

test({
  mode: "nvim",
  ignore: ignore,
  name: "open assignee buffer from issue list",
  fn: async (denops: Denops) => {
    await main(denops);
    await loadAutoload(denops);
    const ctx = newActionContext("gh://skanehira/test/issues");
    ctx.data = { filters: "state:closed assignee:skanehira" };
    await actionListIssue(denops, ctx);
    await denops.call("feedkeys", "ghan");
    await delay(1000);
    assertEquals(await denops.call("getline", 1, "$"), ["skanehira"]);
  },
  timeout: 30000,
});

test({
  mode: "nvim",
  ignore: ignore,
  name: "open label buffer from issue list",
  fn: async (denops: Denops) => {
    await main(denops);
    await loadAutoload(denops);
    const ctx = newActionContext("gh://skanehira/test/issues");
    ctx.data = { filters: "is:open label:bug" };
    await actionListIssue(denops, ctx);
    await denops.call("feedkeys", "ghln");
    await delay(1000);
    assertEquals(await denops.call("getline", 1, "$"), [
      "bug",
      "documentation",
    ]);
  },
  timeout: 30000,
});

test({
  mode: "all",
  name: "not found comments",
  fn: async (denops: Denops) => {
    const ctx = newActionContext(
      "gh://skanehira/test/issues/10/comments",
    );

    await actionListIssueComment(denops, ctx);
    assertEquals(await denops.call("getline", 1), "");
  },
  timeout: 30000,
});

test({
  mode: "all",
  name: "update comment",
  fn: async (denops: Denops) => {
    const ctx = newActionContext(
      "gh://skanehira/test/issues/1/comments/707713426",
    );

    const body = ["テスト4", "テスト5"];
    try {
      await actionEditIssueComment(denops, ctx);
      assertEquals(await denops.call("getline", 1, "$"), body);

      await denops.cmd("%d_");
      await denops.call("setline", 1, ["do something"]);
      await actionUpdateIssueComment(denops, ctx);

      await denops.cmd("bw!");
      await actionEditIssueComment(denops, ctx);
      assertEquals(await denops.call("getline", 1, "$"), ["do something"]);
    } finally {
      await denops.cmd("%d_");
      await denops.call("setline", 1, body);
      await actionUpdateIssueComment(denops, ctx);
    }
  },
  timeout: 30000,
});

test({
  mode: "nvim",
  ignore: ignore,
  name: "open comments buffer from issue list",
  fn: async (denops: Denops) => {
    await main(denops);
    await loadAutoload(denops);
    const ctx = newActionContext("gh://skanehira/test/issues");
    ctx.data = { filters: "is:open title:テスト" };
    await actionListIssue(denops, ctx);
    await denops.call("feedkeys", "ghmn");
    await delay(1000);
    assertEquals(await denops.call("getline", 1, "$"), ["@skanehira test"]);
  },
  timeout: 30000,
});

test({
  mode: "nvim",
  name: "create new issue comment",
  fn: async (denops: Denops) => {
    await denops.call("setline", 1, ["this is it"]);
    const basename = "gh://skanehira/test/issues/27/comments";
    await actionCreateIssueComment(
      denops,
      newActionContext(basename + "/new"),
    );
    await actionListIssueComment(denops, newActionContext(basename));
    const actual = await denops.call("getline", 1, "$");
    assertEquals(actual, ["@skanehira this is it"]);
  },
  timeout: 30000,
});

test({
  mode: "all",
  name: "preview issue body",
  fn: async (denops: Denops) => {
    await loadAutoload(denops);
    const ctx = newActionContext("gh://skanehira/test/issues");
    await actionListIssue(
      denops,
      ctx,
    );
    await actionPreview(denops, ctx);
    const actual =
      (await denops.call("getbufline", "gh:preview", 1, "$") as string[]).join(
        "\n",
      );
    const file = path.join(
      "denops",
      "gh",
      "testdata",
      "want_issue_body_preview.txt",
    );
    await assertEqualTextFile(file, actual);
  },
  timeout: 30000,
});

test({
  mode: "all",
  name: "preview issue comment body",
  fn: async (denops: Denops) => {
    await loadAutoload(denops);
    const ctx = newActionContext("gh://skanehira/test/issues/27/comments");
    await actionListIssueComment(
      denops,
      ctx,
    );
    await actionPreview(denops, ctx);
    const actual =
      (await denops.call("getbufline", "gh:preview", 1, "$") as string[]).join(
        "\n",
      );
    const file = path.join(
      "denops",
      "gh",
      "testdata",
      "want_issue_comment_body_preview.txt",
    );
    await assertEqualTextFile(file, actual);
  },
  timeout: 30000,
});

test({
  mode: "all",
  name: "action yank issue comment urls",
  fn: async (denops: Denops) => {
    await loadAutoload(denops);

    const ctx = newActionContext("gh://skanehira/test/issues/26/comments");
    await actionListIssueComment(denops, ctx);
    await denops.call("gh#_action", "comments:yank");
    const got = await denops.call("getreg", vimRegister);
    const expect =
      "https://github.com/skanehira/test/issues/26#issuecomment-986833117";
    assertEquals(got, expect);
  },
  timeout: 30000,
});

test({
  mode: "all",
  name: "action update issue title from issue list",
  fn: async (denops: Denops) => {
    await loadAutoload(denops);
    await main(denops);
    const ctx = newActionContext("gh://skanehira/test/issues");
    await actionListIssue(denops, ctx);
    await actionEditIssueTitle(denops, ctx);
    await denops.call("setline", 1, ["new title"]);
    const cloneCtx = await getActionCtx(denops);
    await actionUpdateIssueTitle(denops, cloneCtx);
    await actionListIssue(denops, ctx);
    const actual = await denops.call("getline", 1);
    assertEquals(actual, "#27 new title OPEN  ()  1");

    // restore
    await actionEditIssueTitle(denops, ctx);
    await denops.call("setline", 1, ["test2"]);
    await actionUpdateIssueTitle(denops, cloneCtx);
  },
  timeout: 30000,
});
