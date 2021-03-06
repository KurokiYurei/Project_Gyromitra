using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;
using Cinemachine;

public class NewCameraController : MonoBehaviour
{
    [SerializeField]
    private GameManagerScript m_gameManager;

    private PlayerInput playerInput;
    private InputAction moveCamera;

    [SerializeField]
    private PauseMenu m_pauseMenu;

    [SerializeField]
    private GameObject m_normalCamera;

    [SerializeField]
    private GameObject m_aimCamera;

    [SerializeField]
    private Transform m_player;

    [Header("Camera")]
    [SerializeField]
    private float m_MaxPitchDistance = 320f;
    [SerializeField]
    private float m_MinPitchDistance = 60f;

    public void SetNormalCameraDamping(float damp)
    {
        m_normalCamera.GetComponent<CinemachineVirtualCamera>().GetCinemachineComponent<Cinemachine3rdPersonFollow>().Damping.y = damp;
    }

    public void SetFollowAt(bool follow)
    {
        if (follow)
        {
            playerInput.enabled = true;
            m_normalCamera.GetComponent<CinemachineVirtualCamera>().Follow = gameObject.transform;
            m_aimCamera.GetComponent<CinemachineVirtualCamera>().Follow = gameObject.transform;
        }
        else
        {
            playerInput.enabled = false;
            m_normalCamera.GetComponent<CinemachineVirtualCamera>().Follow = null;
            m_normalCamera.transform.forward = transform.forward;
            m_aimCamera.GetComponent<CinemachineVirtualCamera>().Follow = null;
            m_aimCamera.transform.forward = transform.forward;
        }
    }
    public void SetIsAiming(bool l_isAiming)
    {
        if (l_isAiming)
        {
            m_normalCamera.SetActive(false);
            m_aimCamera.SetActive(true);
        }
        else
        {
            m_aimCamera.SetActive(false);
            m_normalCamera.SetActive(true);
        }
    }

    void Start()
    {
        playerInput = GetComponent<PlayerInput>();
        moveCamera = playerInput.actions["Look"];
    }

    void FixedUpdate()
    {
        if (m_gameManager == null)
        {
            m_gameManager = GameObject.Find("GameManager").GetComponent<GameManagerScript>();
        }

        if (!m_pauseMenu.GetPaused())
        {
            Vector2 input = moveCamera.ReadValue<Vector2>();

            string l_mouseSensitivityValue = m_gameManager.Settings.SensitivityMouse.ToString().Replace(",", ".");
            string path = "scaleVector2(x="+l_mouseSensitivityValue+", y="+l_mouseSensitivityValue+")";
            moveCamera.ApplyBindingOverride(0, new InputBinding {overrideProcessors = path });            
            string l_controllerSensitivityValue = m_gameManager.Settings.SensitivityController.ToString().Replace(",", ".");
            string path2 = "scaleVector2(x="+ l_controllerSensitivityValue + ", y="+ l_controllerSensitivityValue + ")";
            moveCamera.ApplyBindingOverride(1, new InputBinding {overrideProcessors = path2 });

            float l_MouseDeltaX = input.x;
            float l_MouseDeltaY = input.y;

            transform.rotation *= Quaternion.AngleAxis(l_MouseDeltaX, Vector3.up);
            transform.rotation *= Quaternion.AngleAxis(-l_MouseDeltaY, Vector3.right);

            var angles = transform.localEulerAngles;
            angles.z = 0;

            var angle = transform.localEulerAngles.x;

            if (angle > 180 && angle < m_MaxPitchDistance)
            {
                angles.x = m_MaxPitchDistance;
            }
            else if (angle < 180 && angle > m_MinPitchDistance)
            {
                angles.x = m_MinPitchDistance;
            }

            transform.localEulerAngles = angles;

            m_player.rotation = Quaternion.Euler(0, transform.rotation.eulerAngles.y, 0);

            Vector3 l_Forward = transform.forward;
            l_Forward.y = 0.0f;
            m_player.forward = l_Forward;

            transform.localEulerAngles = new Vector3(angles.x, 0, 0);
        }    
    }
}
