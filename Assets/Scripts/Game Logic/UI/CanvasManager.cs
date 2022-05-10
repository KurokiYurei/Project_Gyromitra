using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.SceneManagement;

[System.Serializable]
public class ResolutionString
{
    public int m_width;
    public int m_height;
}

public class CanvasManager : MonoBehaviour
{

    [Header("Canvas")]
    [SerializeField]
    private GameObject m_mainMenu;

    [SerializeField]
    private GameObject m_settingsMenu;

    private List<GameObject> m_list;

    private GameObject m_currentCanvas;

    [Header("Resolutions")]
    [SerializeField]
    private List<ResolutionString> resolutionListString;

    [SerializeField]
    private int m_selectedResolution;

    [SerializeField]
    private Text m_textUiResolution;

    [SerializeField]
    private Toggle m_toggleFullScreen;

    [SerializeField]
    private bool m_fullScreen;

    private void Awake()
    {

        // canvas
        m_currentCanvas = m_mainMenu;

        ChangeCanvasToMainMenu();

        // resolution
        m_fullScreen = true;

        m_selectedResolution = 0;

        m_toggleFullScreen.isOn = m_fullScreen;

        CreateResList();

        UpdateTextResolution();
    }

    /// <summary>
    /// Change scene to main game
    /// </summary>
    public void PlayGame()
    {
        SceneManager.LoadScene(SceneManager.GetActiveScene().buildIndex + 1);
    }

    /// <summary>
    /// Exit app
    /// </summary>
    public void ExitGame()
    {
        Application.Quit();
    }

    /// <summary>
    /// Change the canvas to main menu
    /// </summary>
    public void ChangeCanvasToMainMenu()
    {
        m_mainMenu.SetActive(true);
        m_settingsMenu.SetActive(false);
        m_currentCanvas = m_mainMenu;
    }

    /// <summary>
    /// Change the canvas to Settings Menu
    /// </summary>
    public void ChangeCanvasToSettingsMenu()
    {
        m_settingsMenu.SetActive(true);
        m_mainMenu.SetActive(false);
        m_currentCanvas = m_settingsMenu;
    }

    /// <summary>
    /// Create a string list of all the avaliable resolutions
    /// </summary>
    private void CreateResList()
    {
        Resolution[] l_resolutionList = Screen.resolutions;

        List<ResolutionString> l_list = new List<ResolutionString>(l_resolutionList.Length);

        foreach (var res in l_resolutionList)
        {
            ResolutionString l_tempResString = new ResolutionString();

            l_tempResString.m_width = res.width;
            l_tempResString.m_height = res.height;

            l_list.Add(l_tempResString);

            if (Screen.width == l_tempResString.m_width && Screen.height == l_tempResString.m_height)
            {
                m_selectedResolution = l_list.Count - 1;

            }
        }

        resolutionListString = l_list;
    }

    /// <summary>
    /// click left button res 
    /// </summary>
    public void LeftButtonResolution()
    {
        m_selectedResolution--;
        if (m_selectedResolution < 0) m_selectedResolution = 0;

        UpdateTextResolution();
    }

    /// <summary>
    /// click right button res 
    /// </summary>
    public void RightButtonResolution()
    {
        m_selectedResolution++;
        if (m_selectedResolution > resolutionListString.Count - 1) m_selectedResolution = resolutionListString.Count - 1;

        UpdateTextResolution();
    }

    /// <summary>
    /// update the text of the resolution panel 
    /// </summary>
    public void UpdateTextResolution()
    {
        m_textUiResolution.text = resolutionListString[m_selectedResolution].m_width.ToString() + " x " + resolutionListString[m_selectedResolution].m_height.ToString();
    }

    /// <summary>
    /// applyes the graphic changes
    /// </summary>
    public void ApplyGraphics()
    {
        Screen.SetResolution(resolutionListString[m_selectedResolution].m_width, resolutionListString[m_selectedResolution].m_height, m_fullScreen);
    }

    /// <summary>
    /// toogle full screen change value script
    /// </summary>
    /// <param name="l_newVal"></param>
    public void ChangeToggleFullScreen(bool l_newVal)
    {
        m_fullScreen = l_newVal;
    }

}