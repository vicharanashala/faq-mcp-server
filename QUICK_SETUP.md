# Quick Setup Guide - GitHub Secrets Configuration

## ✅ Step 1: Push to GitHub - COMPLETE

Changes have been successfully pushed to GitHub:
- Commit: `b262399`
- Branch: `main`
- Repository: `kshitijpandey3h/faq-mcp-server`

---

## 🔑 Step 2: Create Docker Hub Access Token

### Instructions:

1. **Go to Docker Hub Security Settings**
   - Open: https://hub.docker.com/settings/security
   - Log in to your Docker Hub account if needed

2. **Create New Access Token**
   - Click the **"New Access Token"** button
   - Fill in the details:
     - **Description**: `GitHub Actions - FAQ MCP Server`
     - **Access permissions**: Select **"Read & Write"**
   - Click **"Generate"**

3. **Copy the Token**
   - ⚠️ **IMPORTANT**: Copy the token immediately
   - You won't be able to see it again!
   - Keep it safe for the next step

---

## 🔐 Step 3: Configure GitHub Secrets

### Instructions:

1. **Navigate to Repository Settings**
   - Go to: https://github.com/kshitijpandey3h/faq-mcp-server/settings/secrets/actions
   - Or manually:
     - Go to your repository
     - Click **"Settings"** tab
     - Click **"Secrets and variables"** → **"Actions"**

2. **Add DOCKERHUB_USERNAME Secret**
   - Click **"New repository secret"**
   - Name: `DOCKERHUB_USERNAME`
   - Secret: `vicharanashala` (your Docker Hub username)
   - Click **"Add secret"**

3. **Add DOCKERHUB_TOKEN Secret**
   - Click **"New repository secret"** again
   - Name: `DOCKERHUB_TOKEN`
   - Secret: Paste the token you copied from Docker Hub
   - Click **"Add secret"**

4. **Verify Secrets**
   - You should see both secrets listed:
     - ✅ `DOCKERHUB_USERNAME`
     - ✅ `DOCKERHUB_TOKEN`

---

## 🚀 Step 4: Trigger First Deployment

After configuring the secrets, you have two options:

### Option A: Tag-based Release (Recommended)

```bash
cd /home/ubuntu/Kshitij/Chat-bot/faq-mcp-server

# Create version tag
git tag v1.0.0

# Push tag to trigger workflow
git push origin v1.0.0
```

This will automatically trigger the GitHub Actions workflow.

### Option B: Manual Trigger

1. Go to: https://github.com/kshitijpandey3h/faq-mcp-server/actions
2. Click on **"Docker Hub Publish"** workflow
3. Click **"Run workflow"** button
4. Select branch: `main`
5. Click **"Run workflow"**

---

## 📊 Step 5: Monitor Deployment

1. **Watch the Build**
   - Go to: https://github.com/kshitijpandey3h/faq-mcp-server/actions
   - Click on the running workflow
   - Monitor the progress in real-time

2. **Expected Steps**:
   - ✅ Checkout repository
   - ✅ Set up Docker Buildx
   - ✅ Log in to Docker Hub
   - ✅ Extract metadata
   - ✅ Build and push Docker image (this takes 5-10 minutes)
   - ✅ Image digest

3. **Build Time**: First build takes ~5-10 minutes due to multi-platform compilation

---

## ✅ Step 6: Verify on Docker Hub

After the workflow completes successfully:

1. **Check Docker Hub Repository**
   - Go to: https://hub.docker.com/r/kshitijpandey3h/faq-mcp-server
   - Verify the image appears with tags:
     - `latest`
     - `1.0.0` (if you used tag v1.0.0)
     - `main-<git-sha>`

2. **Test the Image Locally**
   ```bash
   # Pull the image
   docker pull kshitijpandey3h/faq-mcp-server:latest
   
   # Verify multi-platform support
   docker buildx imagetools inspect kshitijpandey3h/faq-mcp-server:latest
   
   # Run the container
   docker run -d \
     --name faq-mcp-test \
     -p 9010:9010 \
     -e MONGODB_URI="your-mongodb-uri" \
     kshitijpandey3h/faq-mcp-server:latest
   
   # Check logs
   docker logs faq-mcp-test -f
   
   # Clean up
   docker stop faq-mcp-test
   docker rm faq-mcp-test
   ```

---

## 🎯 Quick Links

| Resource | URL |
|----------|-----|
| GitHub Repository | https://github.com/kshitijpandey3h/faq-mcp-server |
| GitHub Actions | https://github.com/kshitijpandey3h/faq-mcp-server/actions |
| GitHub Secrets Settings | https://github.com/kshitijpandey3h/faq-mcp-server/settings/secrets/actions |
| Docker Hub Security | https://hub.docker.com/settings/security |
| Docker Hub Repository | https://hub.docker.com/r/kshitijpandey3h/faq-mcp-server |

---

## 🆘 Troubleshooting

### Issue: "Error: Cannot perform an interactive login"

**Solution**: 
- Verify both secrets are configured correctly
- Check that `DOCKERHUB_TOKEN` is a valid access token (not your password)
- Ensure the token has "Read & Write" permissions

### Issue: Workflow doesn't trigger on tag

**Solution**:
- Ensure tag follows pattern `v*.*.*` (e.g., `v1.0.0`)
- Verify the workflow file is on the `main` branch
- Check GitHub Actions is enabled for your repository

### Issue: Build fails with "manifest unknown"

**Solution**:
- Ensure the Docker Hub repository exists
- Verify repository name matches: `kshitijpandey3h/faq-mcp-server`
- Check repository visibility (public or you have access)

---

## 📝 Next Steps After Successful Deployment

1. ✅ Update your LibreChat or other services to use the Docker Hub image
2. ✅ Share the Docker Hub link with your team
3. ✅ Document the deployment process for future releases
4. ✅ Set up automated testing before deployment (optional)

---

**Ready to proceed?** Follow the steps above in order, and you'll have your FAQ MCP Server deployed to Docker Hub! 🚀
