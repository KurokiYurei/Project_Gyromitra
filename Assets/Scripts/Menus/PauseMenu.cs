using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.SceneManagement;
using UnityEngine.UI;

public class PauseMenu : MonoBehaviour
{
    private bool m_paused;

    private GameManagerScript m_gameManager;

    [SerializeField]
    private GameObject m_blur;

    [Header("Menus")]
    [SerializeField]
    private GameObject m_pauseMenu;

    [SerializeField]
    private PlayerInput playerInput;

    [SerializeField]
    private InputAction m_pauseGame;

    [Header("Resolutions")]
    [SerializeField]
    private List<ResolutionString> resolutionList;

    [SerializeField]
    private int m_selectedResolution;

    [SerializeField]
    private Text m_textUiResolution;

    [SerializeField]
    private Toggle m_toggleFullScreen;

    [SerializeField]
    private bool m_fullScreen;

    [Header("Settings")]
    [SerializeField]
    private float m_musicVolume;

    [SerializeField]
    private float m_sfxVolume;

    [SerializeField]
    private float m_sensitivityMouse;

    [SerializeField]
    private float m_sensitivityController;

    [SerializeField]
    private Slider m_musicSlider;

    [SerializeField]
    private Slider m_sfxSlider;

    [SerializeField]
    private Slider m_sensitivityMouseSlider;

    [SerializeField]
    private Slider m_sensitivityControllerSlider;

    [SerializeField]
    private Text m_musicText;

    [SerializeField]
    private Text m_sfxText;

    [SerializeField]
    private Text m_sensitivityMouseText;

    [SerializeField]
    private Text m_sensitivityControllerText;

    public bool GetPaused()
    {
        return m_paused;
    }

    void Start()
    {
        m_pauseGame = playerInput.actions["Pause"];
        m_selectedResolution = 0;
    }

    // Update is called once per frame
    void Update()
    {
        if (m_pauseGame.triggered)
        {
            PauseGame();
        }

        if (m_gameManager == null)
        {
            m_gameManager = GameObject.Find("GameManager").GetComponent<GameManagerScript>();
            UpdateValuesSettings();
        }

    }

    public void UpdateValuesSettings()
    {

        m_musicSlider.value = m_gameManager.Settings.MusicVolume;
        m_sfxSlider.value = m_gameManager.Settings.SfxVolume;
        m_sensitivityMouseSlider.value = m_gameManager.Settings.SensitivityMouse;
        m_sensitivityControllerSlider.value = m_gameManager.Settings.SensitivityController;
        m_toggleFullScreen.isOn = m_gameManager.Settings.FullScreen;

        // resolution
        m_fullScreen = m_gameManager.Settings.FullScreen;

        m_selectedResolution = 0;

        m_toggleFullScreen.isOn = m_fullScreen;

        CreateResList();

        UpdateTextResolution();

        // settings

        m_musicVolume = m_gameManager.Settings.MusicVolume;
        m_sfxVolume = m_gameManager.Settings.SfxVolume;
        m_sensitivityMouse = m_gameManager.Settings.SensitivityMouse;
        m_sensitivityController = m_gameManager.Settings.SensitivityController;

        SetSettingsValues();

    }

    public void PauseGame()
    {
        if (m_paused == true)
        {
            Cursor.lockState = CursorLockMode.Locked;
            m_pauseMenu.SetActive(false);
            Time.timeScale = 1.0f;
            playerInput.actions["Shoot"].Enable();
            Cursor.visible = false;
            m_blur.SetActive(false);
            m_paused = false;
        }
        else
        {
            Cursor.lockState = CursorLockMode.Confined;
            m_pauseMenu.SetActive(true);
            Time.timeScale = 0.0f;
            playerInput.actions["Shoot"].Disable();
            Cursor.visible = true;
            m_blur.SetActive(true);
            m_paused = true;
        }
    }

    public void Quit()
    {
        SceneManager.LoadScene(SceneManager.GetActiveScene().buildIndex - 1);
    }

    private void CreateResList()
    {
        Resolution[] l_resolutionList = Screen.resolutions;

        List<ResolutionString> l_list = new List<ResolutionString>(l_resolutionList.Length);

        foreach (var res in l_resolutionList)
        {
            ResolutionString l_tempResString = new ResolutionString(res.width, res.height);

            l_list.Add(l_tempResString);

            if (m_gameManager.Settings.Resoution.m_width == l_tempResString.m_width && m_gameManager.Settings.Resoution.m_height == l_tempResString.m_height)
            {
                m_selectedResolution = l_list.Count - 1;

            }
        }

        resolutionList = l_list;
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
        if (m_selectedResolution > resolutionList.Count - 1) m_selectedResolution = resolutionList.Count - 1;

        UpdateTextResolution();
    }

    /// <summary>
    /// update the text of the resolution panel 
    /// </summary>
    public void UpdateTextResolution()
    {
        m_textUiResolution.text = resolutionList[m_selectedResolution].m_width.ToString() + " x " + resolutionList[m_selectedResolution].m_height.ToString();
    }

    /// <summary>
    /// applyes the graphic changes
    /// </summary>
    public void ApplySettings()
    {
        // sounds
        m_gameManager.Settings.MusicVolume = m_musicSlider.value;
        m_gameManager.Settings.SfxVolume = m_sfxSlider.value;
        m_gameManager.Settings.SensitivityMouse = m_sensitivityMouseSlider.value;
        m_gameManager.Settings.SensitivityController = m_sensitivityControllerSlider.value;

        // fullscreen 
        m_gameManager.Settings.FullScreen = m_fullScreen;

        // resolution
        m_gameManager.Settings.Resoution = resolutionList[m_selectedResolution];

        // apply the values
        Screen.SetResolution(resolutionList[m_selectedResolution].m_width, resolutionList[m_selectedResolution].m_height, m_fullScreen);
    }

    /// <summary>
    /// toogle full screen change value script
    /// </summary>
    /// <param name="l_newVal"></param>
    public void ChangeToggleFullScreen(bool l_newVal)
    {
        m_fullScreen = l_newVal;
    }

    /// <summary>
    /// Set the starting values for the sliders in the setting
    /// </summary>
    private void SetSettingsValues()
    {
        m_musicSlider.value = m_musicVolume;
        m_sfxSlider.value = m_sfxVolume;
        m_sensitivityMouseSlider.value = m_sensitivityMouse;
        m_sensitivityControllerSlider.value = m_sensitivityController;
        UpdateTextSliders();
    }

    public void SetMusicVolume()
    {
        m_musicVolume = m_musicSlider.value;
        UpdateTextSliders();
    }

    public void SetSFXVolume()
    {
        m_sfxVolume = m_sfxSlider.value;
        UpdateTextSliders();
    }

    public void SetSensitivityMouse()
    {
        m_sensitivityMouse = m_sensitivityMouseSlider.value;
        UpdateTextSliders();
    }

    public void SetSensitivityController()
    {
        m_sensitivityController = m_sensitivityControllerSlider.value;
        UpdateTextSliders();
    }

    private void UpdateTextSliders()
    {
        m_musicText.text = m_musicSlider.value.ToString("0.0");
        m_sfxText.text = m_sfxSlider.value.ToString("0.0");
        m_sensitivityMouseText.text = m_sensitivityMouseSlider.value.ToString("0.0#");
        m_sensitivityControllerText.text = m_sensitivityControllerSlider.value.ToString("0.0#");
    }
}
